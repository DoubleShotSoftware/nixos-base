#!/usr/bin/env bash
#
# libvirt-mem-balloon.sh with additional sanity checks
#
# Policies:
#  - Under high pressure (usage ≥ THRESHOLD_UP): rapidly increase the allocation in INCREASE_STEP increments,
#    with a short delay between increases.
#  - Under low pressure (usage ≤ THRESHOLD_DOWN): if low usage is sustained for DECREASE_DELAY seconds,
#    slowly decrease the allocation in DECREASE_STEP increments (never going below MIN_MEM).
#
# Requirements:
#   - jq must be installed on the host.
#   - The guest agent must support guest-exec and guest-exec-status.
#

LOG_DIR="/var/lib/libvirt-memory"

# Configuration from environment variables (set by Nix)
IGNORE_VMS=${IGNORE_VMS:-""}
MEMORY_STEP_MB=${MEMORY_STEP_MB:-512}
THRESHOLD_UP=${THRESHOLD_UP:-70}
THRESHOLD_DOWN=${THRESHOLD_DOWN:-40}
MEMORY_PRESSURE_MB=${MEMORY_PRESSURE_MB:-512}
INCREASE_DELAY=${INCREASE_DELAY:-30}
DECREASE_DELAY=${DECREASE_DELAY:-300}

# Convert to internal units
INCREASE_STEP=$((MEMORY_STEP_MB * 1024))   # Convert MB to kB
DECREASE_STEP=$((MEMORY_STEP_MB * 1024))   # Convert MB to kB

mkdir -p "$LOG_DIR"

#----------------------------------------------------------------------
# check_guest_agent
#
# Checks if the guest agent appears to be configured by attempting to run guest-get-osinfo.
# Returns 0 if the agent responds without error, nonzero otherwise.
#----------------------------------------------------------------------
check_guest_agent() {
  local vm=$1
  local osinfo
  osinfo=$(virsh qemu-agent-command "$vm" '{"execute": "guest-get-osinfo"}' 2>&1)
  if echo "$osinfo" | grep -qi "error:"; then
    return 1
  fi
  return 0
}

#----------------------------------------------------------------------
# get_guest_meminfo
#
# Uses the guest agent (guest-exec) to run "/bin/cat /proc/meminfo" inside the guest.
# If any error is detected, an empty string is output.
#----------------------------------------------------------------------
get_guest_meminfo() {
  local vm=$1 response pid status encoded meminfo

  response=$(virsh qemu-agent-command "$vm" '{
    "execute": "guest-exec",
    "arguments": {
      "path": "cat",
      "arg": ["/proc/meminfo"],
      "capture-output": true
    }
  }' 2>&1)
  if echo "$response" | grep -qi "error:"; then
    return 1
  fi

  pid=$(echo "$response" | jq '.return.pid')
  # Allow a moment for the command to complete.
  sleep 1
  status=$(virsh qemu-agent-command "$vm" "{
    \"execute\": \"guest-exec-status\",
    \"arguments\": { \"pid\": $pid }
  }" 2>&1)
  if echo "$status" | grep -qi "error:"; then
    return 1
  fi

  encoded=$(echo "$status" | jq -r '.return["out-data"]')
  meminfo=$(echo "$encoded" | base64 --decode)
  echo "$meminfo"
  return 0
}

#----------------------------------------------------------------------
# get_guest_memory_usage
#
# Parses /proc/meminfo (from the guest) to extract:
#   - guest_total (the guest's total memory, in kB)
#   - guest_used  (computed as total minus available, in kB)
#   - guest_available (in kB)
#   - usage (percentage used)
#
# Outputs four space-separated numbers: total used available usage%
# If an error occurs (or if total is 0), returns nonzero.
#----------------------------------------------------------------------
get_guest_memory_usage() {
  local vm=$1 meminfo total available used usage

  meminfo=$(get_guest_meminfo "$vm")
  if [ $? -ne 0 ] || [ -z "$meminfo" ]; then
    return 1
  fi

  total=$(echo "$meminfo" | awk '/MemTotal/ {print $2}')
  available=$(echo "$meminfo" | awk '/MemAvailable/ {print $2}')
  # Sanity check: if total is empty or 0, bail out.
  if [ -z "$total" ] || [ "$total" -eq 0 ]; then
    return 1
  fi
  used=$(( total - available ))
  usage=$(( 100 * used / total ))
  echo "$total $used $available $usage"
  return 0
}

#----------------------------------------------------------------------
# get_current_mem
#
# Retrieves the current balloon allocation ("actual") from virsh dommemstat for the VM.
# If the command fails or returns an empty value, outputs nothing.
#----------------------------------------------------------------------
get_current_mem() {
  local vm=$1 stats current
  stats=$(virsh dommemstat "$vm" 2>/dev/null)
  current=$(echo "$stats" | awk '/actual/ {print $2}')
  echo "$current"
}

#----------------------------------------------------------------------
# get_max_mem
#
# Retrieves the maximum memory from VM XML definition (more reliable than dommemstat usable).
# If the command fails or returns an empty value, outputs nothing.
#----------------------------------------------------------------------
get_max_mem() {
  local vm=$1 max_mem
  max_mem=$(virsh dumpxml "$vm" | grep "<memory unit='KiB'>" | sed "s/.*<memory unit='KiB'>\([0-9]*\)<\/memory>.*/\1/")
  echo "$max_mem"
}

#----------------------------------------------------------------------
# get_min_mem
#
# Retrieves the minimum memory from VM XML definition (currentMemory element).
# This is the memory the VM starts with and represents the configured minimum.
# If the command fails or returns an empty value, outputs nothing.
#----------------------------------------------------------------------
get_min_mem() {
  local vm=$1 min_mem
  min_mem=$(virsh dumpxml "$vm" | grep "<currentMemory unit='KiB'>" | sed "s/.*<currentMemory unit='KiB'>\([0-9]*\)<\/currentMemory>.*/\1/")
  echo "$min_mem"
}

#----------------------------------------------------------------------
# should_ignore_vm
#
# Checks if a VM is in the ignore list
#----------------------------------------------------------------------
should_ignore_vm() {
  local vm=$1
  # If ignore list is empty, don't ignore anything
  [ -z "$IGNORE_VMS" ] && return 1
  # Convert comma-separated IGNORE_VMS to array and check
  echo ",$IGNORE_VMS," | grep -q ",$vm,"
}

#----------------------------------------------------------------------
# Main loop: Process each running VM.
#----------------------------------------------------------------------
for VM in $(virsh list --name); do
  [[ -z "$VM" ]] && continue

  # Skip VMs in ignore list
  if should_ignore_vm "$VM"; then
    echo "[$(date)] Skipping $VM: in ignore list ($IGNORE_VMS)" >> "$LOG_DIR/libvirt-mem.log"
    continue
  fi

  echo "[$(date)] Checking $VM:"

  # Check that the guest agent is available
  if ! check_guest_agent "$VM"; then
    echo "[$(date)] Skipping $VM: guest agent not configured or unreachable." >> "$LOG_DIR/libvirt-mem.log"
    continue
  fi

  # Retrieve current balloon allocation, minimum, and maximum allowed.
  current_mem=$(get_current_mem "$VM")
  min_mem=$(get_min_mem "$VM")
  max_mem=$(get_max_mem "$VM")
  if [ -z "$current_mem" ] || [ -z "$min_mem" ] || [ -z "$max_mem" ]; then
    echo "[$(date)] Skipping $VM: unable to retrieve memory data (current: $current_mem, min: $min_mem, max: $max_mem)." >> "$LOG_DIR/libvirt-mem.log"
    continue
  fi

  # Retrieve guest memory usage from /proc/meminfo via the guest agent.
  guest_usage_out=$(get_guest_memory_usage "$VM")
  if [ $? -ne 0 ] || [ -z "$guest_usage_out" ]; then
    echo "[$(date)] Skipping $VM: unable to retrieve guest memory usage." >> "$LOG_DIR/libvirt-mem.log"
    continue
  fi
  read guest_total guest_used guest_available usage <<< "$guest_usage_out"

  # Calculate memory pressure indicators
  available_mb=$((guest_available / 1024))
  current_mem_gb=$((current_mem / 1024 / 1024))
  min_mem_gb=$((min_mem / 1024 / 1024))
  max_mem_gb=$((max_mem / 1024 / 1024))

  echo "    Balloon: ${current_mem_gb}GB (${current_mem} kB), Min: ${min_mem_gb}GB, Max: ${max_mem_gb}GB"
  echo "    Guest: Total=${guest_total} kB, Available=${available_mb}MB, Usage=${usage}%"
  echo "    Thresholds: Increase≥${THRESHOLD_UP}%, Decrease≤${THRESHOLD_DOWN}%, Pressure<${MEMORY_PRESSURE_MB}MB"

  # Files to record last bump-up and bump-down times.
  LAST_BUMP_UP_FILE="$LOG_DIR/$VM.last_bump_up"
  LAST_BUMP_DOWN_FILE="$LOG_DIR/$VM.last_bump_down"

  last_bump_up=0
  last_bump_down=0
  [[ -f "$LAST_BUMP_UP_FILE" ]] && last_bump_up=$(cat "$LAST_BUMP_UP_FILE")
  [[ -f "$LAST_BUMP_DOWN_FILE" ]] && last_bump_down=$(cat "$LAST_BUMP_DOWN_FILE")
  CURRENT_TIME=$(date +%s)

  #--------------------
  # Case 1: High usage OR memory pressure → Bump-Up
  #--------------------
  if [[ $usage -ge $THRESHOLD_UP ]] || [[ $available_mb -lt $MEMORY_PRESSURE_MB ]]; then
    if [[ $((CURRENT_TIME - last_bump_up)) -ge $INCREASE_DELAY ]]; then
      new_mem=$(( current_mem + INCREASE_STEP ))
      if [[ $new_mem -gt $max_mem ]]; then
        new_mem=$max_mem
      fi
      if [[ $new_mem -gt $current_mem ]]; then
        reason="Usage: ${usage}%"
        [[ $available_mb -lt $MEMORY_PRESSURE_MB ]] && reason="$reason, Low available: ${available_mb}MB"
        echo "[$(date)] Increasing memory for $VM from ${current_mem_gb}GB to $((new_mem/1024/1024))GB ($reason)" >> "$LOG_DIR/libvirt-mem.log"
        virsh setmem "$VM" "${new_mem}" --live
        echo "$CURRENT_TIME" > "$LAST_BUMP_UP_FILE"
      else
        echo "[$(date)] $VM is already at the maximum allocation (${current_mem} kB >= target ${new_mem} kB)." >> "$LOG_DIR/libvirt-mem.log"
      fi
    fi

  #--------------------
  # Case 2: Low usage → Slow Bump-Down
  #--------------------
  elif [[ $usage -le $THRESHOLD_DOWN ]]; then
    if [[ $((CURRENT_TIME - last_bump_down)) -ge $DECREASE_DELAY ]]; then
      new_mem=$(( current_mem - DECREASE_STEP ))
      if [[ $new_mem -lt $min_mem ]]; then
        new_mem=$min_mem
      fi
      if [[ $new_mem -lt $current_mem ]]; then
        echo "[$(date)] Decreasing memory for $VM from ${current_mem_gb}GB to $((new_mem/1024/1024))GB (Usage: ${usage}%)" >> "$LOG_DIR/libvirt-mem.log"
        virsh setmem "$VM" "${new_mem}" --live
        echo "$CURRENT_TIME" > "$LAST_BUMP_DOWN_FILE"
      else
        echo "[$(date)] $VM is already at or below the minimum allocation (${current_mem} kB <= target ${new_mem} kB, min ${min_mem_gb}GB)." >> "$LOG_DIR/libvirt-mem.log"
      fi
    fi

  else
    echo "[$(date)] No change for $VM (Usage: ${usage}%)." >> "$LOG_DIR/libvirt-mem.log"
  fi

done

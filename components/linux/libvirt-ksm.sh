#!/usr/bin/env bash
#
# libvirt-ksm.sh - Kernel Same-Page Merging Configuration
#
# KSM is a memory-saving feature that scans memory pages and merges identical
# pages, useful for virtualization environments where multiple VMs may have
# identical memory pages.
#
# References:
# - https://docs.kernel.org/admin-guide/mm/ksm.html
# - https://www.kernel.org/doc/Documentation/vm/ksm.txt
#
# Monitoring KSM Effectiveness:
#   cat /sys/kernel/mm/ksm/pages_shared    # Pages currently shared
#   cat /sys/kernel/mm/ksm/pages_sharing   # Sites sharing those pages (savings)
#   cat /sys/kernel/mm/ksm/pages_unshared  # Unique pages checked repeatedly
#   cat /sys/kernel/mm/ksm/full_scans      # Number of complete scans
#   cat /sys/kernel/mm/ksm/pages_volatile  # Pages changing too fast
#
# Calculate memory savings:
#   Saved MB = (pages_sharing * 4096) / 1024 / 1024
#
# Monitor CPU usage:
#   top -p $(pgrep ksmd)

set -euo pipefail

# Configuration from environment variables (set by Nix)
PAGES_TO_SCAN=${PAGES_TO_SCAN:-1000}
SLEEP_MILLISECS=${SLEEP_MILLISECS:-20}
MERGE_ACROSS_NODES=${MERGE_ACROSS_NODES:-0}
USE_ZERO_PAGES=${USE_ZERO_PAGES:-1}
MAX_PAGE_SHARING=${MAX_PAGE_SHARING:-256}
SMART_SCAN=${SMART_SCAN:-1}

# Verify KSM is available
if [ ! -d /sys/kernel/mm/ksm ]; then
  echo "KSM not available in kernel"
  exit 1
fi

# Configure Core Parameters
echo "$PAGES_TO_SCAN" > /sys/kernel/mm/ksm/pages_to_scan
echo "$SLEEP_MILLISECS" > /sys/kernel/mm/ksm/sleep_millisecs
echo "$MERGE_ACROSS_NODES" > /sys/kernel/mm/ksm/merge_across_nodes
echo "$USE_ZERO_PAGES" > /sys/kernel/mm/ksm/use_zero_pages
echo "$MAX_PAGE_SHARING" > /sys/kernel/mm/ksm/max_page_sharing

# Configure Modern Features (Linux 6.4+)
if [ -f /sys/kernel/mm/ksm/smart_scan ]; then
  echo "$SMART_SCAN" > /sys/kernel/mm/ksm/smart_scan
fi

# Enable KSM (must be last)
echo 1 > /sys/kernel/mm/ksm/run

echo "KSM configured successfully"
echo "  pages_to_scan: $PAGES_TO_SCAN"
echo "  sleep_millisecs: $SLEEP_MILLISECS"
echo "  merge_across_nodes: $MERGE_ACROSS_NODES"
echo "  use_zero_pages: $USE_ZERO_PAGES"
echo "  max_page_sharing: $MAX_PAGE_SHARING"
echo "  smart_scan: $SMART_SCAN"

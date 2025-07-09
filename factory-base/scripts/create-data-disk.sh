#!/usr/bin/env nix-shell
#!nix-shell -i bash -p cryptsetup btrfs-progs openssh gnupg age util-linux qemu jq

set -e # Exit immediately if a command exits with a non-zero status
CWD=$(pwd)

# Initialize variables
LOOPDEV=""
MOUNT_POINT=""

# Comprehensive cleanup function
cleanup() {
    # Don't cleanup if we completed successfully
    if [ "$SUCCESS" = true ]; then
        return
    fi
    
    echo "Cleaning up due to error or interruption..."
    cd "$CWD" 2>/dev/null || true
    
    # Unmount if mounted
    if [ -n "$MOUNT_POINT" ] && mountpoint -q "$MOUNT_POINT" 2>/dev/null; then
        echo "Unmounting $MOUNT_POINT..."
        umount "$MOUNT_POINT" 2>/dev/null || umount -f "$MOUNT_POINT" 2>/dev/null || true
    fi
    
    # Close LUKS device if open
    if [ -e /dev/mapper/cryptdata ]; then
        echo "Closing LUKS device..."
        cryptsetup luksClose cryptdata 2>/dev/null || true
    fi
    
    # Detach loop device if attached
    if [ -n "$LOOPDEV" ] && losetup -a 2>/dev/null | grep -q "$LOOPDEV"; then
        echo "Detaching loop device $LOOPDEV..."
        losetup -d "$LOOPDEV" 2>/dev/null || true
    fi
    
    # Remove temporary mount point
    if [ -n "$MOUNT_POINT" ] && [ -d "$MOUNT_POINT" ]; then
        rmdir "$MOUNT_POINT" 2>/dev/null || rm -rf "$MOUNT_POINT" 2>/dev/null || true
    fi
    
    sync
}

# Ensure cleanup runs on exit, error, or interruption
trap cleanup EXIT ERR INT TERM

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root (e.g., sudo $0)"
    exit 1
fi

# Check if required arguments are provided
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: sudo $0 <size_in_GB> <image_file_name> [options]"
    echo "Options:"
    echo "  --format qcow2|raw      Image format (default: qcow2)"
    echo "  --tokens-json PATH      Path to JSON file with access tokens"
    echo "  --edit-tokens           Launch editor to create tokens JSON"
    echo "  --vm-flake-output NAME  NixOS flake output name for the VM"
    echo "  --vm-repo URL           Git repository URL for VM configuration"
    echo "  --vm-branch BRANCH      Git branch to use (default: main)"
    exit 1
fi

# Required arguments
IMAGE_SIZE_GB="$1"
IMAGE_FILE="$2"
shift 2

# Parse optional arguments
FORMAT="qcow2"
TOKENS_JSON=""
EDIT_TOKENS=false
VM_FLAKE_OUTPUT=""
VM_REPO=""
VM_BRANCH="main"

while [[ $# -gt 0 ]]; do
    case $1 in
        --format)
            FORMAT="$2"
            shift 2
            ;;
        --tokens-json)
            TOKENS_JSON="$2"
            # Convert relative path to absolute
            if [[ ! "$TOKENS_JSON" =~ ^/ ]]; then
                TOKENS_JSON="$CWD/$TOKENS_JSON"
            fi
            shift 2
            ;;
        --edit-tokens)
            EDIT_TOKENS=true
            shift
            ;;
        --vm-flake-output)
            VM_FLAKE_OUTPUT="$2"
            shift 2
            ;;
        --vm-repo)
            VM_REPO="$2"
            shift 2
            ;;
        --vm-branch)
            VM_BRANCH="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# LUKS container label
LUKS_LABEL="enc_cryptdata"

# Generate a unique temporary mount point
UUID=$(uuidgen)
MOUNT_POINT="/tmp/$UUID"

# Success flag for cleanup logic
SUCCESS=false

# Validation function
validate_inputs() {
    echo "=== Validating Inputs ==="
    
    # Validate size
    if ! [[ "$IMAGE_SIZE_GB" =~ ^[0-9]+$ ]]; then
        echo "ERROR: Size must be a positive integer (got: $IMAGE_SIZE_GB)"
        exit 1
    fi
    
    if [ "$IMAGE_SIZE_GB" -lt 1 ]; then
        echo "ERROR: Size must be at least 1GB"
        exit 1
    fi
    
    # Validate image file name
    if [[ "$IMAGE_FILE" =~ \.qcow2$ ]]; then
        echo "ERROR: Do not include .qcow2 extension in image name"
        echo "  Wrong: vm-data.img.qcow2"
        echo "  Right: vm-data.img"
        exit 1
    fi
    
    # Validate format
    if [ "$FORMAT" != "qcow2" ] && [ "$FORMAT" != "raw" ]; then
        echo "ERROR: Format must be 'qcow2' or 'raw' (got: $FORMAT)"
        exit 1
    fi
    
    # Validate tokens file if provided
    if [ -n "$TOKENS_JSON" ]; then
        if [ ! -f "$TOKENS_JSON" ]; then
            echo "ERROR: Tokens file not found: $TOKENS_JSON"
            exit 1
        fi
        
        if [ ! -r "$TOKENS_JSON" ]; then
            echo "ERROR: Cannot read tokens file: $TOKENS_JSON"
            exit 1
        fi
        
        # Test JSON validity
        if ! jq empty "$TOKENS_JSON" 2>/dev/null; then
            echo "ERROR: Invalid JSON in $TOKENS_JSON:"
            jq . "$TOKENS_JSON" 2>&1 | head -5
            exit 1
        fi
        
        echo "  Tokens file: $TOKENS_JSON (valid JSON)"
        echo "  Domains: $(jq -r 'keys | join(", ")' "$TOKENS_JSON")"
    fi
    
    # Check for existing resources that would conflict
    echo
    echo "=== Checking System State ==="
    
    if [ -e /dev/mapper/cryptdata ]; then
        echo "ERROR: LUKS device /dev/mapper/cryptdata already exists"
        echo "To fix: sudo cryptsetup luksClose cryptdata"
        exit 1
    fi
    
    # Check for stale loop devices using our image
    if [ -f "$IMAGE_FILE" ] && losetup -a 2>/dev/null | grep -q "$IMAGE_FILE"; then
        echo "ERROR: Loop device already using $IMAGE_FILE"
        echo "To fix: sudo losetup -d \$(losetup -j $IMAGE_FILE | cut -d: -f1)"
        exit 1
    fi
    
    echo "  No conflicting resources found"
    echo
}

# Repository access validation
validate_repo_access() {
    # Skip if no VM repo specified
    if [ -z "$VM_REPO" ]; then
        return 0
    fi
    
    echo
    echo "=== Validating Repository Access ==="
    
    # Check if tokens file exists when repo is specified
    if [ -z "$TOKENS_JSON" ] || [ ! -f "$TOKENS_JSON" ]; then
        echo "WARNING: No tokens file provided, repository access cannot be validated"
        echo "The VM may fail to clone the repository during cutover"
        return 0
    fi
    
    # Extract domain from repo URL
    REPO_DOMAIN=$(echo "$VM_REPO" | sed -E 's|https?://([^/]+)/.*|\1|')
    if [ -z "$REPO_DOMAIN" ]; then
        echo "WARNING: Could not parse domain from repository URL: $VM_REPO"
        return 0
    fi
    
    echo "  Repository: $VM_REPO"
    echo "  Domain: $REPO_DOMAIN"
    
    # Check if we have a token for this domain
    if ! jq -e --arg domain "$REPO_DOMAIN" '.[$domain]' "$TOKENS_JSON" >/dev/null 2>&1; then
        echo "ERROR: No token found for domain '$REPO_DOMAIN' in tokens file"
        echo "Please add a token for this domain to your tokens.json file"
        exit 1
    fi
    
    # Create temporary directory for test
    TEST_DIR=$(mktemp -d)
    trap "rm -rf $TEST_DIR" EXIT
    
    # Extract token for the domain
    TOKEN=$(jq -r --arg domain "$REPO_DOMAIN" '.[$domain]' "$TOKENS_JSON")
    
    # Build authenticated URL for testing
    if [ "$REPO_DOMAIN" = "gitlab.com" ]; then
        AUTH_URL=$(echo "$VM_REPO" | sed "s|https://|https://oauth2:$TOKEN@|")
    else
        AUTH_URL=$(echo "$VM_REPO" | sed "s|https://|https://$TOKEN@|")
    fi
    
    # Test repository access directly with authenticated URL
    echo "  Testing repository access..."
    if git ls-remote "$AUTH_URL" >/dev/null 2>&1; then
        echo "  ✓ Successfully validated access to repository"
    else
        echo
        echo "ERROR: Unable to access repository $VM_REPO"
        echo
        echo "Please verify:"
        echo "  - Token for '$REPO_DOMAIN' is correct in $TOKENS_JSON"
        echo "  - Repository URL is correct"
        echo "  - You have access to this repository"
        echo "  - The repository exists"
        echo
        echo "Debug: Try manually running:"
        echo "  git ls-remote $VM_REPO"
        exit 1
    fi
    
    echo "  Repository validation successful"
}

# Run validation
validate_inputs
validate_repo_access

# Progress tracking
TOTAL_STEPS=7
CURRENT_STEP=0

step() {
    CURRENT_STEP=$((CURRENT_STEP + 1))
    echo
    echo "[$CURRENT_STEP/$TOTAL_STEPS] $1"
    echo "========================================="
}

# Check if the image file already exists
if [ -f "$IMAGE_FILE" ]; then
    read -p "Image file $IMAGE_FILE already exists. Overwrite? [y/N]: " response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "Exiting."
        exit 1
    fi
    rm -f "$IMAGE_FILE"
fi

step "Creating raw image file (${IMAGE_SIZE_GB}GB)"
truncate -s "${IMAGE_SIZE_GB}G" "$IMAGE_FILE"

# Set up a loop device for the image file
LOOPDEV=$(losetup --show -f "$IMAGE_FILE")
echo "Loop device $LOOPDEV created."

step "Setting up LUKS encryption"
echo "You will be prompted for a passphrase."
cryptsetup luksFormat --type luks2 --label "${LUKS_LABEL}" "$LOOPDEV"

step "Opening LUKS volume"

# Check if cryptdata already exists
if [ -e /dev/mapper/cryptdata ]; then
    echo "WARNING: /dev/mapper/cryptdata already exists, closing it first..."
    cryptsetup luksClose cryptdata 2>/dev/null || true
fi

echo "Enter passphrase to open the volume:"
cryptsetup luksOpen "$LOOPDEV" cryptdata

step "Creating Btrfs filesystem"
mkfs.btrfs -L enc_cryptdata /dev/mapper/cryptdata

step "Mounting filesystem and creating subvolumes"
mkdir -p "$MOUNT_POINT"
mount /dev/mapper/cryptdata "$MOUNT_POINT"

# Verify mount succeeded
if ! mountpoint -q "$MOUNT_POINT"; then
    echo "ERROR: Failed to mount Btrfs volume at $MOUNT_POINT"
    exit 1
fi

cd "$MOUNT_POINT"
# Create the required subvolumes
btrfs subvolume create "@home"
btrfs subvolume create "@home.snapshots"
btrfs subvolume create "@etc"
btrfs subvolume create "@var"
btrfs subvolume create "@var_log"
btrfs subvolume create "@var_lib"
echo "Subvolumes created successfully"

step "Generating SSH keys and age key"
mkdir -p "$MOUNT_POINT/@etc/ssh"
ssh-keygen -t ed25519 -f "$MOUNT_POINT/@etc/ssh/ssh_host_ed25519_key" -N ''
ssh-keygen -t rsa -b 4096 -f "$MOUNT_POINT/@etc/ssh/ssh_host_rsa_key" -N ''

# Create directories for the age key
echo "Creating directories for age key..."
mkdir -p "$MOUNT_POINT/@var_lib/sops"

# Generate an age key for secret decryption
echo "Generating age key..."
age-keygen -o "$MOUNT_POINT/@var_lib/sops/age.key"
chmod 600 "$MOUNT_POINT/@var_lib/sops/age.key"
# Assuming the age key is at $MOUNT_POINT/var/lib/sops/age.key
PUBLIC_KEY=$(grep "^# public key:" "$MOUNT_POINT/@var_lib/sops/age.key" | sed 's/# public key: //')
echo "Add the following public key to your .sops.yaml:"
echo
echo "creation_rules:"
echo "  - age: $PUBLIC_KEY"
echo "    encrypted_regex: '^(data|stringData)$'"
echo "    path_regex: '.*'"
echo

step "Setting up access tokens and storing public keys"
mkdir -p "$MOUNT_POINT/@etc/gitops"

# Create tokens file from template or editor
TOKENS_TEMP="/tmp/vm-tokens-$$"
if [ "$EDIT_TOKENS" = true ]; then
    echo "Launching editor to create tokens JSON..."
    cat > "$TOKENS_TEMP" <<'EOF'
{
  "github.com": "ghp_xxxxxxxxxxxxxxxxxxxx",
  "gitlab.com": "glpat_xxxxxxxxxxxxxxxxxxxx",
  "gitea.local": "token_xxxxxxxxxxxxxxxxxxxx"
}
EOF
    ${EDITOR:-vi} "$TOKENS_TEMP"
    
    # Validate JSON
    if jq . "$TOKENS_TEMP" > /dev/null 2>&1; then
        cp "$TOKENS_TEMP" "$MOUNT_POINT/@etc/gitops/tokens.json"
    else
        echo "ERROR: Invalid JSON in tokens file"
        rm -f "$TOKENS_TEMP"
        exit 1
    fi
    rm -f "$TOKENS_TEMP"
elif [ -n "$TOKENS_JSON" ]; then
    echo "Copying tokens from $TOKENS_JSON..."
    
    # Check if file exists
    if [ ! -f "$TOKENS_JSON" ]; then
        echo "ERROR: Tokens file not found: $TOKENS_JSON"
        exit 1
    fi
    
    # Validate JSON
    if ! jq . "$TOKENS_JSON" > /dev/null 2>&1; then
        echo "ERROR: Invalid JSON in $TOKENS_JSON"
        echo "JSON validation error:"
        jq . "$TOKENS_JSON" 2>&1 | grep -v "^{" | grep -v "^}" || true
        exit 1
    fi
    
    # Copy tokens file
    cp "$TOKENS_JSON" "$MOUNT_POINT/@etc/gitops/tokens.json"
fi

# Create VM configuration if parameters provided
if [ -n "$VM_FLAKE_OUTPUT" ] || [ -n "$VM_REPO" ]; then
    echo "Creating VM configuration..."
    
    # Validate required parameters
    if [ -z "$VM_FLAKE_OUTPUT" ]; then
        echo "ERROR: --vm-flake-output is required when specifying VM configuration"
        exit 1
    fi
    if [ -z "$VM_REPO" ]; then
        echo "ERROR: --vm-repo is required when specifying VM configuration"
        exit 1
    fi
    
    # Create VM config JSON
    cat > "$MOUNT_POINT/@etc/gitops/vm-config.json" <<EOF
{
  "flakeOutput": "$VM_FLAKE_OUTPUT",
  "repo": "$VM_REPO",
  "branch": "$VM_BRANCH"
}
EOF
    
    echo "VM configuration created:"
    echo "  Flake output: $VM_FLAKE_OUTPUT"
    echo "  Repository: $VM_REPO"
    echo "  Branch: $VM_BRANCH"
fi

# Set permissions on gitops directory
chmod 755 "$MOUNT_POINT/@etc/gitops"  # Directory readable by all
if [ -f "$MOUNT_POINT/@etc/gitops/tokens.json" ]; then
    chmod 600 "$MOUNT_POINT/@etc/gitops/tokens.json"  # Tokens only readable by root
fi
if [ -f "$MOUNT_POINT/@etc/gitops/vm-config.json" ]; then
    chmod 644 "$MOUNT_POINT/@etc/gitops/vm-config.json"  # VM config readable by all
fi
echo "GitOps configuration stored in encrypted volume"

# Store public keys for reference
echo "Storing public keys..."
mkdir -p "$MOUNT_POINT/@etc/vm-keys"
echo "$PUBLIC_KEY" > "$MOUNT_POINT/@etc/vm-keys/age.pub"
cp "$MOUNT_POINT/@etc/ssh/ssh_host_ed25519_key.pub" "$MOUNT_POINT/@etc/vm-keys/"
cp "$MOUNT_POINT/@etc/ssh/ssh_host_rsa_key.pub" "$MOUNT_POINT/@etc/vm-keys/"
chmod 644 "$MOUNT_POINT/@etc/vm-keys"/*

echo

step "Finalizing disk image"

# Return to original directory
cd "$CWD"

# Cleanly unmount
echo "Unmounting filesystem..."
sync  # Ensure all writes are flushed
sleep 1
if ! umount "$MOUNT_POINT" 2>/dev/null; then
    echo "WARNING: Normal unmount failed, attempting force unmount..."
    umount -f "$MOUNT_POINT" 2>/dev/null || true
fi

# Close LUKS
echo "Closing LUKS volume..."
if ! cryptsetup luksClose cryptdata 2>/dev/null; then
    echo "WARNING: LUKS close failed, may be in use"
    sleep 2
    cryptsetup luksClose cryptdata 2>/dev/null || true
fi

# Detach loop device
echo "Detaching loop device..."
if [ -n "$LOOPDEV" ]; then
    losetup -d "$LOOPDEV" 2>/dev/null || true
fi

# Clean up mount point
if [ -n "$MOUNT_POINT" ] && [ -d "$MOUNT_POINT" ]; then
    rmdir "$MOUNT_POINT" 2>/dev/null || true
fi

# Mark as successful BEFORE conversion
SUCCESS=true

# Convert to qcow2 if requested
if [ "$FORMAT" = "qcow2" ]; then
    echo
    echo "Converting to qcow2 format..."
    qemu-img convert -f raw -O qcow2 "$IMAGE_FILE" "${IMAGE_FILE}.qcow2"
    rm -f "$IMAGE_FILE"
    echo "Created: ${IMAGE_FILE}.qcow2"
    echo
    echo "=== Success! ==="
    echo "Disk image: ${IMAGE_FILE}.qcow2"
else
    echo
    echo "=== Success! ==="
    echo "Disk image: $IMAGE_FILE"
fi

if [ -n "$TOKENS_JSON" ]; then
    echo "Tokens stored in encrypted volume"
fi
echo "Age public key: $PUBLIC_KEY"

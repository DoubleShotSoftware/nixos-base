#!/usr/bin/env bash
# VM Cutover Script - Manual process to configure VM from factory image
# Run this after first boot and LUKS unlock

set -e

echo "=== VM Factory Cutover Script ==="
echo "This will configure the VM based on embedded/provided configuration"
echo

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "ERROR: This script must be run as root"
    exit 1
fi

# Check if config file exists
CONFIG_FILE="/etc/gitops/vm-config.json"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "ERROR: Configuration file not found at $CONFIG_FILE"
    echo "Ensure the encrypted disk is mounted and contains VM configuration"
    exit 1
fi

# Parse configuration
echo "Reading configuration from $CONFIG_FILE..."
FLAKE_OUTPUT=$(jq -r .flakeOutput "$CONFIG_FILE")
REPO=$(jq -r .repo "$CONFIG_FILE")
BRANCH=$(jq -r .branch "$CONFIG_FILE")

echo "Configuration:"
echo "  Flake output: $FLAKE_OUTPUT"
echo "  Repository: $REPO"
echo "  Branch: $BRANCH"
echo

# Confirm before proceeding
read -p "Proceed with cutover? (yes/no): " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
    echo "Cutover cancelled"
    exit 0
fi

# Check if persistent volume is mounted
if ! mountpoint -q /persist; then
    echo "ERROR: /persist is not mounted"
    echo "Ensure the encrypted volume is unlocked and mounted"
    exit 1
fi

# Wait for gitops token setup to complete
echo "Checking GitOps token setup..."
if ! systemctl is-active --quiet gitops-token-setup.service; then
    echo "Waiting for GitOps token setup to complete..."
    systemctl start gitops-token-setup.service || true
    sleep 2
fi

# Verify git credentials exist for nix-gitops user
if [ ! -f "/var/lib/nix-gitops/.git-credentials" ]; then
    echo "ERROR: Git credentials not found for nix-gitops user"
    echo "Ensure tokens are configured in /etc/gitops/tokens.json"
    exit 1
fi

# Check for existing configuration
if [ -d "/persist/nixos" ]; then
    echo "WARNING: /persist/nixos already exists"
    read -p "Remove existing configuration? (yes/no): " REMOVE
    if [ "$REMOVE" == "yes" ]; then
        rm -rf /persist/nixos
    else
        echo "Cutover cancelled"
        exit 0
    fi
fi

# Clone the configuration repository
echo
echo "Cloning configuration repository..."

# Create directory structure as root first
echo "Creating configuration directory..."
mkdir -p /persist/nixos
chown nix-gitops:nix-gitops /persist/nixos

# Git will automatically use credentials from ~/.git-credentials
# which were set up by the gitops-token-setup service
# Run as nix-gitops user to use proper credentials
if ! sudo -u nix-gitops git clone --branch "$BRANCH" "$REPO" /persist/nixos; then
    echo "ERROR: Failed to clone repository"
    echo "Check network connectivity and git credentials"
    echo "Ensure tokens are configured in /etc/gitops/tokens.json"
    exit 1
fi

# Fix ownership of cloned repo for nixos-rebuild
chown -R root:root /persist/nixos

echo
echo "Repository cloned successfully"

# Verify the flake exists
if [ ! -f "/persist/nixos/flake.nix" ]; then
    echo "ERROR: No flake.nix found in repository"
    exit 1
fi

# Check if the flake output configuration exists
echo
echo "Checking for VM configuration..."
if ! nix flake show "/persist/nixos#nixosConfigurations.$FLAKE_OUTPUT" &>/dev/null; then
    echo "ERROR: Configuration for flake output '$FLAKE_OUTPUT' not found in flake"
    echo "Available configurations:"
    nix flake show /persist/nixos --json | jq -r '.nixosConfigurations | keys[]' || true
    exit 1
fi

echo "Configuration found for $FLAKE_OUTPUT"

# Create a link for convenience
ln -sfn /persist/nixos /etc/nixos

# Perform the rebuild
echo
echo "Rebuilding system with new configuration..."
echo "This may take a while on first run..."

if nixos-rebuild switch --flake "/persist/nixos#$FLAKE_OUTPUT"; then
    echo
    echo "=== Cutover Successful! ==="
    echo
    echo "The VM has been configured with flake output: $FLAKE_OUTPUT"
    echo "Configuration location: /persist/nixos"
    echo
    echo "Next steps:"
    echo "1. Verify services are running correctly"
    echo "2. Set up any VM-specific secrets"
    echo "3. Enable automatic updates if desired:"
    echo "   systemctl enable --now nixos-upgrade.timer"
    echo
else
    echo
    echo "ERROR: Rebuild failed"
    echo "Check the error messages above"
    echo "The VM is still running the factory configuration"
    exit 1
fi
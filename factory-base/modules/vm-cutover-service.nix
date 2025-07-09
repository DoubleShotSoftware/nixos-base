# VM Cutover Service Module
# Runs the cutover process as nix-gitops user with proper credentials
{ config, lib, pkgs, ... }:
with lib;
{
  config = {
    # Systemd service for VM cutover
    systemd.services.vm-cutover = {
      description = "VM Factory Cutover Service";
      after = [ "gitops-token-setup.service" "persist.mount" ];
      requires = [ "gitops-token-setup.service" "persist.mount" ];
      
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        StandardOutput = "journal+console";
        StandardError = "journal+console";
        
        # Environment
        Environment = [
          "HOME=/root"
          "PATH=/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin"
          "GIT_ASKPASS="  # Prevent git from trying to prompt
          "GIT_TERMINAL_PROMPT=0"  # Disable terminal prompts
        ];
      };
      
      script = ''
        set -e
        
        echo "=== VM Factory Cutover Service ==="
        echo "Running as user: $(whoami)"
        echo
        
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
        
        # Check if persistent volume is mounted
        if [ ! -d "/persist" ]; then
            echo "ERROR: /persist directory does not exist"
            echo "Ensure the encrypted volume is unlocked and mounted"
            exit 1
        fi
        
        # Verify git credentials exist
        if [ ! -f "$HOME/.git-credentials" ]; then
            echo "ERROR: Git credentials not found at $HOME/.git-credentials"
            echo "Ensure gitops-token-setup service completed successfully"
            exit 1
        fi
        
        echo "Git credentials found at $HOME/.git-credentials"
        
        # Check for existing configuration
        if [ -d "/persist/nixos" ]; then
            echo "WARNING: /persist/nixos already exists"
            echo "Removing existing configuration..."
            rm -rf /persist/nixos
        fi
        
        # Create directory
        echo "Creating configuration directory..."
        mkdir -p /persist/nixos
        
        # Clone the configuration repository
        echo
        echo "Cloning configuration repository..."
        echo "Repository: $REPO"
        echo "Branch: $BRANCH"
        
        # Extract domain from repo URL and get token
        REPO_DOMAIN=$(echo "$REPO" | sed -E 's|https?://([^/]+)/.*|\1|')
        TOKEN=$(jq -r --arg domain "$REPO_DOMAIN" '.[$domain] // empty' /etc/gitops/tokens.json)
        
        if [ -n "$TOKEN" ]; then
            # Construct authenticated URL
            AUTH_REPO=$(echo "$REPO" | sed "s|https://|https://$TOKEN@|")
            echo "Using token authentication for $REPO_DOMAIN"
        else
            echo "WARNING: No token found for domain $REPO_DOMAIN, trying without authentication"
            AUTH_REPO="$REPO"
        fi
        
        # Clone with authenticated URL
        if ! git clone --branch "$BRANCH" "$AUTH_REPO" /persist/nixos; then
            echo "ERROR: Failed to clone repository"
            echo "Check network connectivity and git credentials"
            exit 1
        fi
        
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
      '';
    };
  };
}
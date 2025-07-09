# GitOps Token Management Module
# Converts JSON tokens to nix.conf and git credentials formats
{ config, lib, pkgs, ... }:
with lib;
{
  config = {
    # Systemd service to setup tokens after persistent disk mount
    systemd.services.gitops-token-setup = {
      description = "Setup GitOps access tokens";
      after = [ "persist.mount" ];
      wantedBy = [ "multi-user.target" ];
      
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        User = "root";
      };
      
      script = ''
        set -e
        
        # Check if tokens file exists
        if [ ! -f "${config.factory.constants.tokensPath}" ]; then
          echo "No tokens file found at ${config.factory.constants.tokensPath}"
          exit 0
        fi
        
        # Create directories
        mkdir -p "$(dirname ${config.factory.constants.nixAccessTokensPath})"
        
        # Convert JSON to nix access-tokens format
        echo "Converting tokens to nix.conf format..."
        TOKENS=$(${pkgs.jq}/bin/jq -r 'to_entries | map("\(.key)=\(.value)") | join(" ")' "${config.factory.constants.tokensPath}")
        echo "access-tokens = $TOKENS" > "${config.factory.constants.nixAccessTokensPath}"
        chmod 644 "${config.factory.constants.nixAccessTokensPath}"
        
        # Create git credentials for nix-gitops user
        echo "Creating git credentials..."
        > "${config.factory.constants.gitCredentialsPath}"
        
        # Convert each token to git credential format
        ${pkgs.jq}/bin/jq -r 'to_entries[] | 
          if .key == "gitlab.com" then
            "https://oauth2:\(.value)@\(.key)"
          else
            "https://\(.value)@\(.key)"
          end' "${config.factory.constants.tokensPath}" >> "${config.factory.constants.gitCredentialsPath}"
        
        # Set proper permissions (root owns it)
        chmod 600 "${config.factory.constants.gitCredentialsPath}"
        
        # Configure git for root user
        ${pkgs.git}/bin/git config --global credential.helper store
        
        echo "GitOps tokens configured successfully"
      '';
    };
  };
}
# VM Configuration Seeding Module
# Provides configuration for VMs to identify themselves and their config source
{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.vm.config;
in {
  options.vm.config = {
    enable = mkEnableOption "VM configuration seeding";
    
    hostname = mkOption {
      type = types.str;
      description = "The hostname this VM should configure itself as";
      example = "web-01";
    };
    
    repo = mkOption {
      type = types.str;
      description = "Git repository containing VM configurations";
      example = "git+ssh://gitea.local/infrastructure/vm-configs";
    };
    
    branch = mkOption {
      type = types.str;
      default = "main";
      description = "Git branch to use";
    };
    
    method = mkOption {
      type = types.enum [ "embedded" "kernel-cmdline" "systemd-creds" ];
      default = "embedded";
      description = ''
        Method for providing configuration:
        - embedded: Bake into image at build time
        - kernel-cmdline: Pass via kernel parameters
        - systemd-creds: Use systemd credentials
      '';
    };
    
    gitCredentialsFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = ''
        Path to git credentials file to inject during build.
        This file will be copied to /etc/vm-secrets/git-credentials
        with restricted permissions.
      '';
    };
  };
  
  config = mkIf cfg.enable (mkMerge [
    # Common configuration for all methods
    {
      # Ensure git is available for cloning
      environment.systemPackages = [ pkgs.git ];
      
      # Copy git credentials if provided
      environment.etc = mkIf (cfg.gitCredentialsFile != null) {
        "vm-secrets/git-credentials" = {
          source = cfg.gitCredentialsFile;
          mode = "0600";
          user = "root";
          group = "root";
        };
      };
    }
    
    # Embedded configuration method
    (mkIf (cfg.method == "embedded") {
      environment.etc."vm-config.json".text = builtins.toJSON {
        inherit (cfg) hostname repo branch;
      };
    })
    
    # Kernel cmdline method
    (mkIf (cfg.method == "kernel-cmdline") {
      # Service to read kernel cmdline and create config
      systemd.services.vm-config-from-cmdline = {
        description = "Extract VM configuration from kernel cmdline";
        wantedBy = [ "multi-user.target" ];
        before = [ "vm-cutover.service" ];
        
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        
        script = ''
          # Extract vm.* parameters from /proc/cmdline
          HOSTNAME=$(cat /proc/cmdline | tr ' ' '\n' | grep '^vm\.hostname=' | cut -d= -f2)
          REPO=$(cat /proc/cmdline | tr ' ' '\n' | grep '^vm\.repo=' | cut -d= -f2)
          BRANCH=$(cat /proc/cmdline | tr ' ' '\n' | grep '^vm\.branch=' | cut -d= -f2)
          
          # Default branch if not specified
          BRANCH=''${BRANCH:-main}
          
          # Create config file
          mkdir -p /etc
          cat > /etc/vm-config.json <<EOF
          {
            "hostname": "$HOSTNAME",
            "repo": "$REPO",
            "branch": "$BRANCH"
          }
          EOF
        '';
      };
    })
    
    # SystemD credentials method
    (mkIf (cfg.method == "systemd-creds") {
      # Service to extract credentials
      systemd.services.vm-config-from-creds = {
        description = "Extract VM configuration from systemd credentials";
        wantedBy = [ "multi-user.target" ];
        before = [ "vm-cutover.service" ];
        
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          LoadCredentialEncrypted = "vm.config";
        };
        
        script = ''
          # Copy credential to config location
          cp "$CREDENTIALS_DIRECTORY/vm.config" /etc/vm-config.json
        '';
      };
    })
  ]);
}
# Overlay Store Configuration
# Uses Nix's overlay store feature to separate factory base from VM-specific packages
{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.vm.overlayStore;
in {
  options.vm.overlayStore = {
    enable = mkEnableOption "overlay store for VMs" // {
      default = true;
      description = ''
        Enable overlay store to use factory image as read-only base
        with persistent storage for VM-specific packages.
      '';
    };
    
    upperDir = mkOption {
      type = types.str;
      default = "/persist/nix/store";
      description = "Directory for the overlay upper layer (VM-specific packages)";
    };
    
    workDir = mkOption {
      type = types.str;
      default = "/persist/nix/work";
      description = "Work directory for overlay filesystem";
    };
  };
  
  config = mkIf cfg.enable {
    # Ensure persistent directories exist
    systemd.tmpfiles.rules = [
      "d ${cfg.upperDir} 0755 root root -"
      "d ${cfg.workDir} 0755 root root -"
      "d /persist/nix 0755 root root -"
      "d /persist/nix/var 0755 root root -"
      "d /persist/nix/var/nix 0755 root root -"
      "d /persist/nix/var/nix/profiles 0755 root root -"
      "d /persist/nix/var/nix/gcroots 0755 root root -"
    ];
    
    # Configure Nix to use overlay store
    nix.settings = {
      # Enable required experimental features for overlay store
      experimental-features = [ "nix-command" "flakes" ];
      
      # We'll use a different approach - don't set store here
      # store = ...
      
      # Ensure store optimization works with overlay
      auto-optimise-store = true;
      
      # More aggressive GC since we can re-download from cache
      min-free = mkDefault (1 * 1024 * 1024 * 1024);  # 1 GB
      max-free = mkDefault (5 * 1024 * 1024 * 1024);  # 5 GB
    };
    
    # Create overlay mount service for /nix/store
    systemd.services.nix-store-overlay = {
      description = "Setup overlay mount for Nix store";
      wantedBy = [ "multi-user.target" ];
      after = [ "persist.mount" ];
      requires = [ "persist.mount" ];
      before = [ "nix-daemon.service" ];
      
      # This must run before any service that uses nix
      requiredBy = [ "nix-daemon.service" ];
      
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        # Run as root to perform mounts
        User = "root";
        Group = "root";
      };
      
      path = with pkgs; [
        util-linux  # for mount, umount
        coreutils   # for mkdir, etc
      ];
      
      script = ''
        set -e
        
        echo "Setting up Nix store overlay..."
        
        # Ensure upper and work directories exist
        mkdir -p ${cfg.upperDir}
        mkdir -p ${cfg.workDir}
        
        # Check if store is already writable (e.g., already overlayed)
        if [ -w /nix/store ]; then
          echo "Nix store is already writable, skipping overlay setup"
          exit 0
        fi
        
        # Create a bind mount of the read-only store to use as lower layer
        LOWER_DIR="/nix/.store-lower"
        mkdir -p "$LOWER_DIR"
        
        # Bind mount the current read-only store
        if ! mountpoint -q "$LOWER_DIR"; then
          mount --bind /nix/store "$LOWER_DIR"
        fi
        
        # Now create the overlay mount over /nix/store
        echo "Mounting overlay filesystem..."
        mount -t overlay overlay \
          -o lowerdir="$LOWER_DIR",upperdir=${cfg.upperDir},workdir=${cfg.workDir} \
          /nix/store
        
        echo "Nix store overlay mounted successfully"
        echo "Lower (read-only): $LOWER_DIR"
        echo "Upper (writable): ${cfg.upperDir}"
        echo "Work: ${cfg.workDir}"
      '';
      
      preStop = ''
        # Cleanup on service stop
        if mountpoint -q /nix/store; then
          umount /nix/store || true
        fi
        if mountpoint -q /nix/.store-lower; then
          umount /nix/.store-lower || true
        fi
      '';
    };
    
    # Mount persistent volume before nix-daemon starts
    systemd.services.nix-daemon = {
      after = [ "persist.mount" "nix-store-overlay.service" ];
      requires = [ "persist.mount" "nix-store-overlay.service" ];
    };
    
    # Automatic garbage collection (more aggressive for overlay store)
    nix.gc = {
      automatic = mkDefault true;
      dates = mkDefault "daily";
      options = mkDefault "--delete-older-than 7d";
    };
    
    # Ensure /nix/var is also on persistent storage
    # This includes the Nix database and profiles
    fileSystems."/nix/var" = {
      device = "/persist/nix/var";
      fsType = "none";
      options = [ "bind" "x-systemd.after=persist.mount" ];
    };
    
    # Warning about Nix version requirement
    warnings = optional (cfg.enable && (builtins.compareVersions config.nix.package.version "2.22") < 0) 
      "Overlay store requires Nix 2.22+. Current version: ${config.nix.package.version}";
  };
}
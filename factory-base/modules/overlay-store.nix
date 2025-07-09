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
      "d /persist/nix/var 0755 root root -"
    ];
    
    # Configure Nix to use overlay store
    nix.settings = {
      # Use overlay store with factory /nix as lower layer
      # NOTE: This requires Nix 2.22+
      store = mkDefault "overlay://?lower-store=/nix&upper-layer=${cfg.upperDir}&work-dir=${cfg.workDir}";
      
      # Alternative syntax (pick one based on Nix version)
      # store = "overlay-layers://${cfg.upperDir}:/nix";
      
      # Ensure store optimization works with overlay
      auto-optimise-store = true;
      
      # More aggressive GC since we can re-download from cache
      min-free = mkDefault (1 * 1024 * 1024 * 1024);  # 1 GB
      max-free = mkDefault (5 * 1024 * 1024 * 1024);  # 5 GB
    };
    
    # Mount persistent volume before nix-daemon starts
    systemd.services.nix-daemon = {
      after = [ "persist.mount" ];
      requires = [ "persist.mount" ];
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
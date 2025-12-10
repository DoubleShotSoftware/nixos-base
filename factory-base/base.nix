# Factory base image configuration
# Provides minimal system that VMs build upon
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
let 
  constants = import ../models/constants.nix;
in
{
  imports = [
    # Factory modules
    ./constants.nix
    ./modules/persistent.nix
    ./modules/overlay-store.nix
    ./modules/vm-config.nix
    ./modules/gitops-tokens.nix
    ./modules/vm-cutover-service.nix
    ./modules/persist-mount.nix
  ];

  # Disable unnecessary security features for minimal size
  security.polkit.enable = false;
  security.rtkit.enable = false;
  
  # Boot configuration - ultra minimal
  boot = {
    # Bare minimum kernel modules
    initrd.availableKernelModules = [
      # VM support
      "virtio_pci"
      "virtio_blk"
      "virtio_net"
      # Encryption
      "dm-crypt"
    ];
    
    # Use standard kernel (not latest)
    kernelPackages = pkgs.linuxPackages;
    
    # Minimal kernel - disable unnecessary features
    kernelParams = [ 
      "quiet"  # Less verbose boot
      "loglevel=3"  # Only errors
    ];
    
    # Disable unnecessary modules
    blacklistedKernelModules = [
      "bluetooth"
      "btusb"
      "uvcvideo"
    ];
  };

  # Minimal networking - just DHCP
  networking = {
    useDHCP = lib.mkDefault true;
    firewall.enable = true;
  };

  # Essential services
  services = {
    # Minimal SSH for remote access
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        X11Forwarding = false;
        UsePAM = false;  # Reduces dependencies
      };
      # Only ED25519 host key (smallest)
      hostKeys = [{
        path = "/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }];
    };

    # Disable QEMU guest agent (can enable after cutover)
    qemuGuest.enable = false;
  };

  # Ultra-minimal packages
  environment.systemPackages = with pkgs; [
    # Absolute essentials only
    gitMinimal  # For cloning config (~25MB vs ~150MB)
    jq          # For parsing config.json (~2MB)
    util-linux  # For mount, mountpoint, etc. (~3MB)
    btrfs-progs # For btrfs filesystem operations (~2MB)
    
    # Cutover command - starts the systemd service
    (writeShellScriptBin "vm-cutover" ''
      echo "Starting VM cutover service..."
      echo "Follow progress with: journalctl -u vm-cutover -f"
      echo
      exec systemctl start vm-cutover.service
    '')
    
    # Unlock helper - unlocks LUKS and mounts persistent volumes
    (writeShellScriptBin "vm-unlock" ''
      echo "=== VM Unlock Helper ==="
      echo
      
      # Check if already unlocked
      if [ -e /dev/mapper/cryptdata ]; then
        echo "Volume already unlocked"
      else
        # Find the encrypted disk (usually /dev/vdb)
        CRYPT_DISK=""
        for disk in /dev/vdb /dev/sdb /dev/xvdb; do
          if [ -b "$disk" ] && cryptsetup isLuks "$disk" 2>/dev/null; then
            CRYPT_DISK="$disk"
            break
          fi
        done
        
        if [ -z "$CRYPT_DISK" ]; then
          echo "ERROR: No LUKS encrypted disk found"
          echo "Checked: /dev/vdb, /dev/sdb, /dev/xvdb"
          exit 1
        fi
        
        echo "Found encrypted disk at $CRYPT_DISK"
        echo "Unlocking LUKS volume..."
        cryptsetup luksOpen "$CRYPT_DISK" cryptdata || exit 1
      fi
      
      # Start the persist-mount service
      echo
      echo "Starting persist-mount service..."
      systemctl start persist-mount.service
      
      # Check status
      if systemctl is-active --quiet persist-mount.service; then
        echo
        echo "✓ Persistent volumes mounted successfully"
        echo
        echo "Next steps:"
        echo "1. Run 'vm-cutover' to complete VM configuration"
        echo "2. Or check mounted files:"
        echo "   - /etc/gitops/vm-config.json"
        echo "   - /persist/"
      else
        echo
        echo "ERROR: Failed to mount persistent volumes"
        echo "Check: journalctl -u persist-mount -xe"
        exit 1
      fi
    '')
  ];
  
  # Disable default packages
  environment.defaultPackages = [];

  # Disable unnecessary features to minimize size
  documentation = {
    enable = lib.mkDefault false;
    doc.enable = false;
    info.enable = false;
    man.enable = false;
    nixos.enable = false;
  };

  # Disable command-not-found
  programs.command-not-found.enable = false;
  
  # Aggressive size reduction
  
  # Disable firmware unless essential
  hardware.enableRedistributableFirmware = false;
  hardware.enableAllFirmware = false;
  
  # Minimal locale support
  i18n.supportedLocales = [ "en_US.UTF-8/UTF-8" ];
  
  # Disable sound
  services.pipewire.enable = false;
  
  # Disable printing
  services.printing.enable = false;
  
  # Disable Avahi
  services.avahi.enable = false;
  
  # Disable udisks
  services.udisks2.enable = false;
  
  # Disable systemd-resolved (use basic resolv.conf)
  services.resolved.enable = false;
  
  # Minimal systemd
  systemd.coredump.enable = false;
  
  # Disable CUPS
  programs.system-config-printer.enable = false;

  # Nix configuration
  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
    };

    # Include access tokens from persistent volume if available
    extraOptions = ''
      !include ${config.factory.constants.nixAccessTokensPath}
    '';

    # Garbage collection
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };

  # VM configuration defaults
  vm.config = {
    enable = lib.mkDefault true;
    method = lib.mkDefault "embedded";
    # These should be overridden per VM
    hostname = lib.mkDefault "factory-vm";
    repo = lib.mkDefault "https://github.com/example/vm-configs";
    branch = lib.mkDefault "main";
  };
  
  # Enable overlay store with proper local-overlay configuration
  vm.overlayStore.enable = true;

  # System state version
  system.stateVersion = constants.nixStateVersion;
  
  # Set a default root password for initial access
  # This should be changed after cutover
  users.users.root.initialPassword = "factory";
  services.getty.autologinUser = "root";
  
  # Ensure users are mutable so passwords can be changed
  users.mutableUsers = true;
  
  # Disable sshd-keygen service since SSH keys come from encrypted disk
  systemd.services.sshd-keygen.enable = false;
  
  # Override disk size for smaller image
  #virtualisation.diskSize = 2048;  # 2GB is the practical minimum for NixOS
}

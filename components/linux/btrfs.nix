{ config, lib, pkgs, ... }:
with lib; {
  options.personalConfig.linux.btrfs = {
    enable = mkOption {
      type = types.bool;
      description = "Enable core btrfs support with snapshots";
      default = false;
    };
    immutable = mkOption {
      type = types.bool;
      description = "Configure mounts for an ephemeral system";
      default = false;
    };
    useDisko = mkOption {
      type = types.bool;
      description = "Use disko for filesystem mounts instead of this module";
      default = false;
    };
    rootDevice = mkOption {
      type = types.str;
      description = "The root btrfs device";
      default = "/dev/mapper/cryptroot";
    };
    defaultSubvolumes = mkOption {
      type = types.attrsOf (types.attrsOf types.anything);
      description = "Default BTRFS subvolume configuration for disko";
      default = {
        "@" = {
          mountpoint = "/";
          mountOptions = [ "compress=zstd" "noatime" ];
        };
        "@home" = {
          mountpoint = "/home";
          mountOptions = [ "compress=zstd" "noatime" ];
        };
        "@nix" = {
          mountpoint = "/nix";
          mountOptions = [ "compress=zstd" "noatime" ];
        };
        "@persist" = {
          mountpoint = "/persist";
          mountOptions = [ "compress=zstd" "noatime" ];
        };
        "@log" = {
          mountpoint = "/var/log";
          mountOptions = [ "compress=zstd" "noatime" ];
        };
        "@home.snapshots" = {
          mountpoint = "/home/.snapshots";
          mountOptions = [ "compress=zstd" "noatime" ];
        };
        "@nix.snapshots" = {
          mountpoint = "/nix/.snapshots";
          mountOptions = [ "compress=zstd" "noatime" ];
        };
        "@persist.snapshots" = {
          mountpoint = "/persist/.snapshots";
          mountOptions = [ "compress=zstd" "noatime" ];
        };
        "@log.snapshots" = {
          mountpoint = "/var/log/.snapshots";
          mountOptions = [ "compress=zstd" "noatime" ];
        };
        "@-empty" = {
          mountpoint = null;  # Don't mount
        };
        "@swap" = {
          mountpoint = null;  # Don't mount
        };
      };
    };
    additionalSubvolumes = mkOption {
      type = types.attrsOf (types.attrsOf types.anything);
      description = "Additional BTRFS subvolumes to create beyond defaults";
      default = {};
      example = {
        "@docker" = {
          mountpoint = "/var/lib/docker";
          mountOptions = [ "compress=zstd" "noatime" ];
        };
      };
    };
    additionalBinds = mkOption {
      type = types.listOf (types.submodule {
        options = {
          source = mkOption {
            type = types.str;
            description = "Source path in /persist";
          };
          destination = mkOption {
            type = types.str;
            description = "Destination path";
          };
          bindType = mkOption {
            type = types.enum [ "directory" "file" ];
            default = "directory";
            description = "Whether to bind mount (directory) or symlink (file)";
          };
        };
      });
      description = "Additional bind mounts or symlinks from /persist";
      default = [];
      example = [
        { source = "/persist/etc/NetworkManager/system-connections"; 
          destination = "/etc/NetworkManager/system-connections";
          bindType = "directory"; }
        { source = "/persist/etc/passwd"; 
          destination = "/etc/passwd";
          bindType = "file"; }
      ];
    };
  };
  config = mkMerge [
    (lib.mkIf config.personalConfig.linux.btrfs.enable
      (trace "Enabling BTRFS core configuration." {
        services.btrfs = {
          autoScrub = {
            enable = true;
            interval = "weekly";
            fileSystems = [ "/" ];
          };
        };
        boot = {
          supportedFilesystems = [ "btrfs" ];
        };
      }))
    (lib.mkIf config.personalConfig.linux.btrfs.immutable
      (trace "Enabling BTRFS Ephemeral Mounts." {
        boot = {
          initrd = {
            postDeviceCommands = lib.mkAfter ''
              echo "Rolling back root filesystem..."
              mkdir -p /mnt
              
              # Wait for cryptroot to be available
              while [ ! -e ${config.personalConfig.linux.btrfs.rootDevice} ]; do
                sleep 0.5
              done
              
              # Mount BTRFS root to manipulate subvolumes
              mount -o subvol=/ ${config.personalConfig.linux.btrfs.rootDevice} /mnt
              
              # Delete current @ and restore from @-empty
              if [ -e /mnt/@-empty ]; then
                # Delete any nested subvolumes in @ first
                btrfs subvolume list -o /mnt/@ 2>/dev/null | cut -f9 -d' ' | while read subvol; do
                  btrfs subvolume delete "/mnt/$subvol" 2>/dev/null || true
                done
                
                # Delete and restore
                btrfs subvolume delete /mnt/@ 2>/dev/null || true
                btrfs subvolume snapshot /mnt/@-empty /mnt/@
                echo "Root rolled back to clean state"
              else
                echo "WARNING: @-empty snapshot not found, skipping rollback"
              fi
              
              umount /mnt
            '';
          };
        };
        fileSystems = mkMerge [
          # Only define filesystem mounts if NOT using disko
          (mkIf (!config.personalConfig.linux.btrfs.useDisko) {
            "/" = {
              device = config.personalConfig.linux.btrfs.rootDevice;
              fsType = "btrfs";
              options = [ "subvol=@" "compress=zstd" "noatime" ];
            };

            "/home" = {
              device = config.personalConfig.linux.btrfs.rootDevice;
              fsType = "btrfs";
              options = [ "subvol=@home" "compress=zstd" "noatime" ];
            };

            "/persist" = {
              device = config.personalConfig.linux.btrfs.rootDevice;
              fsType = "btrfs";
              options = [ "subvol=@persist" "compress=zstd" "noatime" ];
              neededForBoot = true;
            };

            "/nix" = {
              device = config.personalConfig.linux.btrfs.rootDevice;
              fsType = "btrfs";
              options = [ "subvol=@nix" "compress=zstd" "noatime" ];
            };

            "/var/log" = {
              device = config.personalConfig.linux.btrfs.rootDevice;
              fsType = "btrfs";
              options = [ "subvol=@log" "compress=zstd" "noatime" ];
              neededForBoot = true;
            };

            "/var/lib" = {
              device = config.personalConfig.linux.btrfs.rootDevice;
              fsType = "btrfs";
              options = [ "subvol=@var-lib" "compress=zstd" "noatime" ];
              neededForBoot = true;
            };
          })
          
          # Bind mounts are always defined (whether using disko or not)
          {
            # Core bind mounts always needed
            "/etc/nixos" = {
              device = "/persist/etc/nixos";
              fsType = "none";
              options = [ "bind" "X-mount.mkdir" ];
            };

            "/etc/ssh" = {
              device = "/persist/etc/ssh";
              fsType = "none";
              options = [ "bind" "X-mount.mkdir" ];
            };
          }
          
          # Dynamic bind mounts from additionalBinds (directories only)
          (builtins.listToAttrs (map (bind: {
            name = bind.destination;
            value = {
              device = bind.source;
              fsType = "none";
              options = [ "bind" "X-mount.mkdir" ];
              depends = [ "/persist" ];
            };
          }) (filter (b: b.bindType == "directory") config.personalConfig.linux.btrfs.additionalBinds)))
        ];
        
        # Activation script for file symlinks
        system.activationScripts.persistFiles = lib.stringAfter [ "users" "groups" ] ''
          # Ensure persist directories exist
          mkdir -p /persist/etc
          
          # Handle file persistence via symlinks
          ${lib.concatMapStrings (bind: 
            if bind.bindType == "file" then ''
              # Handle ${bind.destination}
              if [ -e "${bind.destination}" ] && [ ! -L "${bind.destination}" ]; then
                # File exists and is not a symlink, copy to persist
                mkdir -p $(dirname "${bind.source}")
                cp -a "${bind.destination}" "${bind.source}"
                rm "${bind.destination}"
              fi
              
              # Create symlink if it doesn't exist
              if [ ! -e "${bind.destination}" ]; then
                mkdir -p $(dirname "${bind.destination}")
                mkdir -p $(dirname "${bind.source}")
                # Create empty file in persist if it doesn't exist
                [ ! -e "${bind.source}" ] && touch "${bind.source}"
                ln -sf "${bind.source}" "${bind.destination}"
              fi
            '' else ""
          ) config.personalConfig.linux.btrfs.additionalBinds}
        '';
      }))
  ];
}
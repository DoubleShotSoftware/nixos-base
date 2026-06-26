{ config, lib, pkgs, ... }:
with lib; {
  options.personalConfig.linux.zfs = {
    enable = mkOption {
      type = types.bool;
      description = "Enable core zfs support auto scrub/snapshot";
      default = false;
    };
    immutable = mkOption {
      type = types.bool;
      description = "Configure mounts for an ephemeral system";
      default = false;
    };
    rootPool = mkOption {
      type = types.str;
      description = "The name of the root zfs pool";
      default = "zroot";
    };
  };
  config = mkMerge [
    (lib.mkIf config.personalConfig.linux.zfs.enable
      (trace "Enabling ZFS core configuration." {
        services.zfs = {
          trim = { enable = true; };
          autoScrub = { enable = true; };
        };
        boot = {
          supportedFilesystems = [ "zfs" ];
          # ZFS kernel module is automatically included when in supportedFilesystems
        };
        systemd.services.zfs-mount.enable = false;
      }))
    (lib.mkIf config.personalConfig.linux.zfs.immutable
      (trace "Enabling ZFS Ephemeral Mounts." {
        # Ephemeral root: roll the root dataset back to its empty snapshot every boot.
        # systemd-initrd (the 26.05 default) does not support the scripted
        # pre/postDeviceCommands, so under it we run a stage-1 service ordered after the
        # pool import and before the root mount. Legacy scripted initrd keeps the old hooks.
        boot.initrd = lib.mkMerge [
          (lib.mkIf config.boot.initrd.systemd.enable {
            systemd.services.rollback-root = {
              description = "Roll back ${config.personalConfig.linux.zfs.rootPool}/root to a pristine snapshot";
              wantedBy = [ "initrd.target" ];
              after = [ "zfs-import-${config.personalConfig.linux.zfs.rootPool}.service" ];
              before = [ "sysroot.mount" ];
              path = [ config.boot.zfs.package ];
              unitConfig.DefaultDependencies = "no";
              serviceConfig.Type = "oneshot";
              script = ''
                zfs rollback -r ${config.personalConfig.linux.zfs.rootPool}/root@empty
              '';
            };
          })
          (lib.mkIf (!config.boot.initrd.systemd.enable) {
            preDeviceCommands = ''
              zpool import -Nf ${config.personalConfig.linux.zfs.rootPool}
            '';
            postDeviceCommands = ''
              zpool import -Nf ${config.personalConfig.linux.zfs.rootPool}
              zfs rollback -r ${config.personalConfig.linux.zfs.rootPool}/root@empty
              zfs rollback -r ${config.personalConfig.linux.zfs.rootPool}/root@empty || true
              zpool export -a
            '';
          })
        ];
        fileSystems = {
          "/" = {
            device = "zroot/root";
            fsType = "zfs";
            options = [ "noatime" "X-mount.mkdir" ];
          };

          "/home" = {
            device = "zroot/home";
            fsType = "zfs";
            options = [ "noatime" "X-mount.mkdir" ];
          };
          "/persist" = {
            device = "zroot/persist";
            fsType = "zfs";
            options = [ "noatime" "X-mount.mkdir" ];
          };

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

          "/nix" = {
            device = "zroot/nix";
            fsType = "zfs";
            options = [ "noatime" "X-mount.mkdir" ];
          };

          "/var/log" = {
            device = "zroot/var/log";
            fsType = "zfs";
            options = [ "noatime" "X-mount.mkdir" ];
          };

          "/var/lib" = {
            device = "zroot/var/lib";
            fsType = "zfs";
            options = [ "noatime" "X-mount.mkdir" ];
          };
        };
      }))
  ];
}

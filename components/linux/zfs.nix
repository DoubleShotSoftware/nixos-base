{ config, lib, pkgs, ... }:
with lib;
{
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
  };
  config = mkMerge [
    (lib.mkIf config.personalConfig.linux.zfs.enable
      (
        trace ''Enabling ZFS core configuration.''
          {
            services.zfs = {
              trim = { enable = true; };
              autoSnapshot = { enable = true; };
              autoScrub = { enable = true; };
            };
            boot.zfs = { forceImportAll = true; };
            systemd.services.zfs-mount.enable = false;
          }
      ))
    (lib.mkIf config.personalConfig.linux.zfs.immutable
      (
        trace ''Enabling ZFS Ephemeral Mounts.''
          {
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
          }
      ))
  ];
}

{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.personalConfig.linux.guest;
  qemuVirtModules = [
    "virtio_net"
    "virtio_console"
    "virtio_balloon"
    "virtio_pci"
    "virtio_pci_modern_dev"
    "virtio"
    "virtio_ring"
    "virtio_blk"
    "virtio_rng"
  ];

  implementation = lib.mkMerge [
    (lib.mkIf (cfg.vmType == "qemu") {
      boot = {
        initrd = {
          availableKernelModules = qemuVirtModules;
          kernelModules = qemuVirtModules;
        };
      };
      services.qemuGuest.enable = true;
    })
    (lib.mkIf ((cfg.vmType == "qemu") && cfg.graphical) {
      services = {
        spice-vdagentd.enable = true;
        spice-webdavd.enable = true;
      };
    })
  ];
in
{
  options.personalConfig.linux.guest = {
    enable = mkEnableOption "Whether instance is a guest type.";
    vmType = mkOption {
      description = "The type of guest vm i.e. parallels or qemu.";
      type = types.enum [ "qemu" ];
      default = "qemu";
    };
    graphical = mkEnableOption "Whether the instance is a graphical instance, installs things like spice vd agent";
  };
  config = lib.mkIf cfg.enable implementation;
}

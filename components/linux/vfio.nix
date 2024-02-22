{ config, lib, options, pkgs, ... }:
with lib;
let
  cfg = config.personalConfig.linux.vfio;
  vfioModules = [ "vfio-pci" ];
in {
  options.personalConfig.linux.vfio = with lib; {
    enable = mkOption {
      type = types.bool;
      description = "Whether to enable vfio support.";
      default = false;
    };
    pciIds = mkOption {
      type = types.listOf types.str;
      description = "A list of pci ids to bind via vfio.";
      default = [ ];
    };
    preemptNvidia = mkOption {
      type = types.bool;
      description = "Whether to preempt nvidia with vfio.";
      default = false;
    };
  };
  config = mkIf cfg.enable (trace "Enabling vfio support" mkMerge [
    {
      boot = {
        initrd = {
          availableKernelModules = vfioModules;
          kernelModules = vfioModules;
        };
        kernelParams = [
          "vfio_iommu_type1.allow_unsafe_interrupts=1"
          ("vfio-pci.ids=" + lib.concatStringsSep "," cfg.pciIds)
        ];
      };
    }
    (mkIf cfg.preemptNvidia {
      boot.kernelParams = [
        "nouveau.driver.pre=vfio-pci"
        "nvidia.driver.pre=vfio-pci"

      ];
    })
  ]);
}

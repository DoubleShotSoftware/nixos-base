{ config, lib, options, pkgs, ... }:
with lib;
let
  cfg = config.personalConfig.linux.vfio;
  vfioModules = [ "vfio-pci" ];
  modProbeConfig = lib.concatStringsSep "\n"
    (map (module: "softdep ${module} pre: vfio-pci") cfg.modProbe);
  kernelPreempt =  
    (map (module: "${module}.driver.pre=vfio-pci") cfg.modProbe);
  kernelBind = ("vfio-pci.ids=" + lib.concatStringsSep "," cfg.pciIds);

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
    preemptModules = mkOption {
      type = types.listOf types.str;
      description = "Modules to pre-empt with vfio";
      default = false;
    };
    modProbe = mkOption {
      type = types.bool;
      description = "Whether to amend vfio args to modprobe.";
      default = false;
    };
    bootCommand = mkOption {
      type = types.bool;
      description = "Whether to amend vfio to to the boot args.";
      default = config.personalConfig.linu.vfio.enable;
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
    (mkIf cfg.modProbe {
        boot.kernelParams = kernelPreempt ++ kernelBind;
    })
    (mkIf cfg.modProbe {
        boot.extraModprobeConfig = modProbeConfig;
    })
  ]);
}

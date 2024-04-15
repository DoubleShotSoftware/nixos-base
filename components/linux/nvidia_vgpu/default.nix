{ config, lib, options, pkgs, ... }:
with builtins;
with lib;
let
  cfg = config.personalConfig.linux.nvidia_vgpu;
  myVgpuVersion = cfg.vgpuVersion;
  nvidia_vgpu = (pkgs.callPackage ./package.nix) {
    kernel = config.boot.kernelPackages.kernel;
    cfg = cfg;
  };

in {
  options.personalConfig.linux.nvidia_vgpu = with lib; {
    enable = lib.mkEnableOption "NVIDIA vGPU Support";
    custom_package_url = mkOption {
      type = types.str;
      description = "URL to a patched nvidia vgpu driver.";
      default =
        "http://192.168.10.118:8000/NVIDIA-Linux-x86_64-550.54.10-vgpu-kvm-custom.run";
    };
    custom_package_sha = mkOption {
      type = types.str;
      default = "sha256-8LNRIulsaZQqLILirdtR2+OO+INv1AnTCMpZxmzhsu4=";
    };

    unlock.enable = lib.mkOption {
      default = false;
      type = lib.types.bool;
      description = "Unlock vGPU functionality for consumer grade GPUs";
    };
    vgpuVersion = lib.mkOption {
      default = "550.54.10";
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ nvidia_vgpu ];
    boot.extraModulePackages = [ nvidia_vgpu ];

    # systemd.services.nvidia-vgpud = {
    # description = "NVIDIA vGPU Daemon";
    # wants = [ "syslog.target" ];
    # wantedBy = [ "multi-user.target" ];
    #
    # serviceConfig = {
    #   Type = "forking";
    #   ExecStart = lib.strings.concatStringsSep " " [
    #     # Won't this just break if cfg.unlock.enable = false?
    #     # (lib.optionalString cfg.unlock.enable
    #     #   "${vgpu_unlock}/bin/vgpu_unlock")
    #     "${lib.getBin config.hardware.nvidia.package}/bin/nvidia-vgpud"
    #   ];
    #   ExecStopPost = "${pkgs.coreutils}/bin/rm -rf /var/run/nvidia-vgpud";
    #   Environment = [
    #     "__RM_NO_VERSION_CHECK=1"
    #   ]; # Avoids issue with API version incompatibility when merging host/client drivers
    #   # };
    # };
  };
}

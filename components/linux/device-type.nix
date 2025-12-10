{ config, lib, options, pkgs, ... }:
with lib;

{
  options.personalConfig.system.deviceType = mkOption {
    type = types.enum [ "desktop" "laptop" "server" "vm" "workstation" ];
    default = "desktop";
    description = ''
      Type of device for hardware-specific configurations.
      - desktop: Traditional desktop computer
      - laptop: Portable computer with battery
      - server: Headless server
      - vm: Virtual machine
      - workstation: High-performance desktop
    '';
    example = "laptop";
  };

  # Convenience options for checking device type
  options.personalConfig.system.isLaptop = mkOption {
    type = types.bool;
    default = config.personalConfig.system.deviceType == "laptop";
    readOnly = true;
    description = "Whether this system is a laptop";
  };

  options.personalConfig.system.isDesktop = mkOption {
    type = types.bool;
    default = config.personalConfig.system.deviceType == "desktop" ||
              config.personalConfig.system.deviceType == "workstation";
    readOnly = true;
    description = "Whether this system is a desktop or workstation";
  };

  options.personalConfig.system.hasDisplay = mkOption {
    type = types.bool;
    default = config.personalConfig.system.deviceType != "server";
    readOnly = true;
    description = "Whether this system has a graphical display";
  };

  options.personalConfig.system.isMobile = mkOption {
    type = types.bool;
    default = config.personalConfig.system.deviceType == "laptop";
    readOnly = true;
    description = "Whether this system is mobile (battery-powered)";
  };
}
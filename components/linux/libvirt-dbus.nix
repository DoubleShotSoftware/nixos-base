{ config, pkgs, lib, ... }:

with lib;
let
  cfg = config.personalConfig.linux.libvirt.dbus;
  libvirtCfg = config.personalConfig.linux.libvirt;

  libvirt-dbus = pkgs.callPackage ../../packages/libvirt-dbus.nix { };
in {
  config = mkIf (libvirtCfg.enable && cfg.enable) {
    # Assertions
    assertions = [
      {
        assertion = config.virtualisation.libvirtd.enable;
        message = "Libvirt D-Bus requires libvirtd to be enabled. Set personalConfig.linux.libvirt.enable = true;";
      }
    ];

    # Add libvirt-dbus package
    environment.systemPackages = [
      libvirt-dbus
    ];

    # Enable libvirt-dbus D-Bus service
    services.dbus.packages = [
      libvirt-dbus
    ];

    # Enable libvirt-dbus systemd service
    systemd.services.libvirt-dbus = {
      description = "Libvirt D-Bus API";
      documentation = [ "https://libvirt.org/dbus.html" ];
      requires = [ "dbus.service" "libvirtd.service" ];
      after = [ "dbus.service" "libvirtd.service" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "dbus";
        BusName = "org.libvirt";
        ExecStart = "${libvirt-dbus}/bin/libvirt-dbus";
      };
    };
  };
}

{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.personalConfig.cockpit;
in
{
  config = mkIf cfg.enable (mkMerge [
    {
      services.cockpit = {
        enable = true;
        port = cfg.port;
        openFirewall = false; # Never expose to WAN

        # Add HTTP origins to enable automatic redirect to HTTPS
        # The module already adds "https://localhost:${port}" by default
        # This merges with that default list
        allowed-origins = [
          "http://localhost:${toString cfg.port}"
          "http://${config.networking.hostName}:${toString cfg.port}"
        ];
      };

      # Ensure polkit is enabled for authentication
      security.polkit.enable = true;
    }

    (mkIf cfg.enableMachines {
      # Add cockpit-machines package
      environment.systemPackages =
        let
          cockpit-machines = pkgs.callPackage ../../packages/cockpit-machines.nix { };
        in
        [
          cockpit-machines
          pkgs.libvirt
          pkgs.virt-manager  # Provides virt-install for VM creation
        ];

      # Ensure libvirt is configured when machines plugin is enabled
      assertions = [
        {
          assertion = config.personalConfig.linux.libvirt.enable or false;
          message = "Cockpit Machines requires libvirt to be enabled. Set personalConfig.linux.libvirt.enable = true;";
        }
        {
          assertion = (config.personalConfig.linux.libvirt.enable or false) -> config.personalConfig.linux.libvirt.dbus.enable;
          message = "Cockpit Machines requires libvirt D-Bus to be enabled. Set personalConfig.linux.libvirt.dbus.enable = true;";
        }
      ];

      # Add systemd tmpfiles rules for cockpit-machines
      systemd.tmpfiles.rules = [
        "L+ /usr/share/cockpit/machines - - - - ${
          pkgs.callPackage ../../packages/cockpit-machines.nix { }
        }/share/cockpit/machines"
      ];
    })
  ]);
}

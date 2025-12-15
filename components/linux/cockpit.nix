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
          # Python with pygobject for libosinfo bindings (used by cockpit-machines)
          pythonWithGi = pkgs.python3.withPackages (ps: [ ps.pygobject3 ]);
        in
        [
          cockpit-machines
          pkgs.libvirt
          pkgs.virt-manager  # Provides virt-install for VM creation
          pkgs.libosinfo     # OS detection library
          pkgs.osinfo-db     # OS information database
          pythonWithGi       # Python with GObject introspection
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

      # Add systemd tmpfiles rules for cockpit-machines and osinfo-db
      systemd.tmpfiles.rules = [
        "L+ /usr/share/cockpit/machines - - - - ${
          pkgs.callPackage ../../packages/cockpit-machines.nix { }
        }/share/cockpit/machines"
        "L+ /usr/share/osinfo - - - - ${pkgs.osinfo-db}/share/osinfo"
      ];

      # Set GI_TYPELIB_PATH for libosinfo GObject introspection (needed by cockpit-machines)
      # libosinfo depends on libxml2 typelib
      environment.sessionVariables.GI_TYPELIB_PATH = lib.mkDefault (lib.concatStringsSep ":" [
        "${pkgs.libosinfo}/lib/girepository-1.0"
        "${pkgs.libxml2}/lib/girepository-1.0"
      ]);

      # Also set for cockpit service specifically
      systemd.services.cockpit.environment.GI_TYPELIB_PATH = lib.concatStringsSep ":" [
        "${pkgs.libosinfo}/lib/girepository-1.0"
        "${pkgs.libxml2}/lib/girepository-1.0"
      ];
    })
  ]);
}

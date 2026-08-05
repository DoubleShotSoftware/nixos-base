{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  personalConfig = config.personalConfig;
  cfg = config.personalConfig.cockpit;
  containerEnabled = personalConfig.linux.container.enable;
  isPodman = personalConfig.linux.container.backend == "podman";
in {
  config = mkIf cfg.enable (mkMerge [
    {
      services.cockpit = {
        enable = true;
        port = cfg.port;
        openFirewall = cfg.openFirewall;
        showBanner = cfg.showBanner;
        package =
          if cfg.package == null
          then pkgs.cockpit
          else cfg.package;
        settings = cfg.settings;

        # Add HTTP origins to enable automatic redirect to HTTPS
        # The module already adds "https://localhost:${port}" by default
        # This merges with that default list
        allowed-origins = [
          "http://localhost:${toString cfg.port}"
          "http://${config.networking.hostName}:${toString cfg.port}"
        ];
        plugins = [pkgs.cockpit-files] ++ cfg.plugins;
      };

      # Ensure polkit is enabled for authentication
      security.polkit.enable = true;
    }
    (mkIf boot.zfs.enabled {
      services.cockpit.plugins = lib.mkAfter [
        pkgs.cockpit-zfs
      ];
    })
    (mkIf (containerEnabled && isPodman) {
      services.cockpit.plugins = lib.mkAfter [
        pkgs.cockpit-podman
      ];
    })

    (mkIf cfg.enableMachines {
      services.cockpit.plugins = lib.mkAfter [
        pkgs.cockpit-machines
      ];

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
    })
  ]);
}

{lib}:
with lib; {
  options = {
    cockpit = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable Cockpit web-based server management interface.
        '';
      };

      enableMachines = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable Cockpit Machines plugin for VM management.
        '';
      };

      plugins = mkOption {
        type = types.listOf types.package;
        default = [];
        description = ''
          Additional Cockpit plugins. Built-in integrations are selected from
          enabled host capabilities.
        '';
      };

      settings = mkOption {
        type = types.attrs;
        default = {};
        description = "Cockpit configuration sections merged into cockpit.conf.";
      };

      package = mkOption {
        type = types.nullOr types.package;
        default = null;
        description = "Cockpit package to use; null uses nixpkgs Cockpit.";
      };

      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = "Open the Cockpit port in the NixOS firewall.";
      };

      showBanner = mkOption {
        type = types.bool;
        default = true;
        description = "Show the Cockpit console banner in issue and MOTD files.";
      };

      port = mkOption {
        type = types.port;
        default = 9090;
        description = ''
          Port for Cockpit web interface.
        '';
      };
    };
  };
}

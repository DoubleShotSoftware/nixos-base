{ lib }:
with lib;
{
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
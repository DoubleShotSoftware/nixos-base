{ lib, ... }:
with lib;
{
  options.personalConfig.networking.mtu = {
    default = mkOption {
      type = types.int;
      default = 1500;
      description = "Default MTU for network interfaces";
    };
    
    adaptive = mkOption {
      type = types.bool;
      default = false;
      description = "Enable TCP Path MTU discovery";
    };
    
    destinations = mkOption {
      type = types.listOf (types.submodule {
        options = {
          ip = mkOption {
            type = types.str;
            description = "Destination IP address";
          };
          prefixLength = mkOption {
            type = types.int;
            default = 32;
            description = "Network prefix length (CIDR notation)";
          };
          mtu = mkOption {
            type = types.int;
            description = "MTU for this destination";
          };
          interfaces = mkOption {
            type = types.listOf types.str;
            default = [];
            description = "Specific interfaces to apply this route to";
          };
        };
      });
      default = [];
      description = "Per-destination MTU routes";
    };
  };
  
  options.personalConfig.constants.mtuRoutes = {
    microsoft = mkOption {
      type = types.listOf types.attrs;
      default = [
        { ip = "13.64.0.0"; prefixLength = 11; mtu = 1380; }
        { ip = "13.96.0.0"; prefixLength = 13; mtu = 1380; }
        { ip = "13.104.0.0"; prefixLength = 14; mtu = 1380; }
        { ip = "20.0.0.0"; prefixLength = 8; mtu = 1380; }
        { ip = "40.64.0.0"; prefixLength = 10; mtu = 1380; }
        { ip = "51.4.0.0"; prefixLength = 15; mtu = 1380; }
        { ip = "51.8.0.0"; prefixLength = 13; mtu = 1380; }
        { ip = "51.16.0.0"; prefixLength = 12; mtu = 1380; }
        { ip = "51.32.0.0"; prefixLength = 11; mtu = 1380; }
        { ip = "51.64.0.0"; prefixLength = 10; mtu = 1380; }
        { ip = "51.128.0.0"; prefixLength = 9; mtu = 1380; }
        { ip = "52.0.0.0"; prefixLength = 6; mtu = 1380; }
        { ip = "104.40.0.0"; prefixLength = 13; mtu = 1380; }
        { ip = "168.61.0.0"; prefixLength = 16; mtu = 1380; }
      ];
      description = "Microsoft/Azure IP ranges requiring special MTU handling";
    };
  };
}
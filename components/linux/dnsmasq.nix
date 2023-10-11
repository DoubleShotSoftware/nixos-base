{ pkgs, lib, config, stdenv, ... }:
with lib;
let
  dnsMasqConfig = config.personalConfig.linux.dnsmasq.interfaces;
  cfg = config.personalConfig.linux.dnsmasq;
  stateDir = "/var/lib/dnsmasq";
  etherOptions = { ... }: {
    options = {
      mac = mkOption {
        type = types.str;
        description = "The mac address";
      };
      hostname = mkOption {
        type = types.str;
        description = "The hostname to bind.";
      };
      ip = mkOption {
        type = types.str;
        description = "The ip address";
      };
    };
  };
  dnsMasqInterfaceOptions = { ... }: {
    options = {
      interface = mkOption {
        type = types.str;
        description = "Interface to run on";
      };
      lowerRange = mkOption {
        type = types.str;
        description = "The lower IP range for the dhcp pool";
      };
      upperRange = mkOption {
        type = types.str;
        description = "The upper IP range for the dhcp pool";
      };
      listenOn = mkOption {
        type = types.str;
        description = "The IP range for the dhcp server to listen on.";
      };
      leaseTime = mkOption {
        type = types.str;
        description = "Lease time for a dhcp address in hours.";
        default = "12";
      };
    };
  };
  listenAddresses = map (interfaceConfig: interfaceConfig.listenOn) dnsMasqConfig;
  interfaceConfigs = map
    (interfaceConfig:
      "${interfaceConfig.interface},${interfaceConfig.lowerRange},${interfaceConfig.upperRange},${interfaceConfig.leaseTime}"
    )
    dnsMasqConfig;
  hosts = builtins.listToAttrs (
    builtins.map
      (
        ether: { value = [ ether.hostname ]; name = ether.ip; }
      )
      cfg.ethers);
in
{
  options.personalConfig.linux.dnsmasq = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
    dnsServers = mkOption {
      type = types.listOf types.str;
      default = [ ];
    };
    interfaces = mkOption {
      default = [ ];
      type = types.listOf (types.submodule dnsMasqInterfaceOptions);
      description = "Configure a interface for dnsmasq.";
    };
    ethers = mkOption {
      default = [ ];
      type = types.listOf (types.submodule etherOptions);
      description = "Configure ethers for dnsmasq.";
    };
  };
  config = mkIf cfg.enable
    {
      environment.etc."ethers" = {
        text = (lib.concatStringsSep "\n" (map (ether: "${ether.mac} ${ether.hostname}") cfg.ethers));
      };
      networking = {
        hosts = hosts;
      };
      services = {
        dnsmasq = {
          enable = true;
          resolveLocalQueries = false;
          settings = {
            conf-file = "${pkgs.dnsmasq}/share/dnsmasq/trust-anchors.conf";
            dnssec = true;
            server = cfg.dnsServers;
            read-ethers = true;
            domain-needed = true;
            bogus-priv = true;
            expand-hosts = true;
            cache-size = 10000;
            dhcp-lease-max = 150;
            bind-interfaces = true;
            log-dhcp = true;
            log-queries = true;
            listen-address = lib.concatStringsSep "," listenAddresses;
            dhcp-range = interfaceConfigs;
          };
        };
      };
    };
}

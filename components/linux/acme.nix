{ config, lib, options, pkgs, ... }:
with lib;
let
  certBotConfig = config.personalConfig.linux.certbot;
in
{
  options.personalConfig.linux.certbot = {
    enable = mkOption {
      default = false;
      type = types.bool;
      description = "Whether to enable certbot.";
    };
    credentialsFile = {
      type = types.path;
      default = /secrets/digitalocean_acme.cfg;
    };
  };
  config = lib.mkMerge [
    (lib.mkIf (certBotConfig.enable) {
      security.acme = {
        acceptTerms = true;
        defaults = {
          credentialsFile = /secrets/digitalocean_acme.cfg;
          dnsProvider = "digitalocean";
          email = "acme_certs@animus.design";
        };
      };
    })
  ];
}

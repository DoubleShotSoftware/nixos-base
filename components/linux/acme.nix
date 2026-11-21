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
    dnsProvider = mkOption {
      type = types.enum [ "route53" "digitalocean" ];
      default = "route53";
      description = "DNS provider for ACME challenges. Route53 is preferred.";
    };
    credentialsFile = mkOption {
      type = types.path;
      default = /secrets/route53_acme.cfg;
      description = "Path to credentials file for DNS provider.";
    };
  };
  config = lib.mkMerge [
    (lib.mkIf (certBotConfig.enable) {
      security.acme = {
        acceptTerms = true;
        defaults = {
          # 25.11/26.05 renamed security.acme.*.credentialsFile → environmentFile
          # (the env-file form: VAR=value lines for the lego DNS provider).
          environmentFile = certBotConfig.credentialsFile;
          dnsProvider = certBotConfig.dnsProvider;
          email = "acme_certs@animus.design";
        };
      };
    })
  ];
}

{ config, lib, options, pkgs, ... }:
with lib;
let
  certScript = "scripts/custom_certs.sh";
  cacertPackage = pkgs.cacert.override {
    extraCertificateStrings = map (cert: builtins.readFile cert) config.personalConfig.linux.customCerts;
    extraCertificateFiles = config.personalConfig.linux.customCerts;
  };
  custom_cert_hooks = mapAttrs
    (user: config:
      (
        trace ''Enabling nvim for user: ${user}''
          {
            programs.zsh = {
              initExtra = ''
                /etc/${certScript}
                export NIX_SSL_CERT_FILE=$HOME/.config/ssl/ssl_bundle.crt
                export SSL_CERT_FILE=$HOME/.config/ssl/ssl_bundle.crt 
              '';
            };
          }
      ))
    config.personalConfig.users;
in
{

  options.personalConfig.linux.customCerts = mkOption {
    type = types.bool;
    description = "Whether to enable custom certs. This will add a custom shell hook for users.";
    default = false;
  };
  config = lib.mkMerge [
    (lib.mkIf (config.personalConfig.linux.customCerts) (
      trace ''Enabling custom certs''
        {
          environment.etc = {
            "${certScript}" = {
              source = ./script.sh;
              mode = "0755";
            };
          };
          home-manager.users = custom_cert_hooks;
        }
    ))
  ];
}


{ config, lib, pkgs, inputs, desktop, ... }:
with lib;
with builtins;
let
  users = config.personalConfig.users;

  # Web server + one-time login token, attached to a user's home-manager config
  # when both zellij and zellijWeb are set. Bound to 127.0.0.1 so it stays local.
  mkZellijWeb = userConfig: let
    port = toString userConfig.zellijWebPort;
    # zellij web --create-token emits the token once and cannot retrieve it later,
    # so generate it idempotently into ~/.config/zellij/tokens/default (0600).
    tokenScript = pkgs.writeShellScript "zellij-web-create-token" ''
      set -eu
      tokenDir="$HOME/.config/zellij/tokens"
      tokenFile="$tokenDir/default"
      if [ ! -s "$tokenFile" ]; then
        ${pkgs.coreutils}/bin/mkdir -p "$tokenDir"
        ${pkgs.coreutils}/bin/install -m 600 /dev/null "$tokenFile"
        ${pkgs.zellij}/bin/zellij web --create-token --token-name default > "$tokenFile"
      fi
    '';
  in {
    systemd.user.services.zellij-web = {
      Unit = {
        Description = "Zellij web server";
        Documentation = [ "man:zellij(1)" ];
      };
      Service = {
        Type = "simple";
        ExecStartPre = "${tokenScript}";
        ExecStart = "${pkgs.zellij}/bin/zellij web --start --ip 127.0.0.1 --port ${port}";
        Restart = "on-failure";
        RestartSec = "5s";
      };
      Install.WantedBy = [ "default.target" ];
    };
  };

  mkZellijUser = user: userConfig:
    if (userConfig.zellij && userConfig.userType == "normal") then
      trace "Enabling zellij for user: ${user}" (mkMerge [
        { programs.zellij.enable = true; }
        (mkIf userConfig.zellijWeb (mkZellijWeb userConfig))
      ])
    else
      { };
in {
  config = mkMerge [
    {
      programs.zsh.enable = true;
      home-manager.users = mapAttrs mkZellijUser
        (filterAttrs (user: userConfig: userConfig.userType != "system") users);
    }
  ];
}

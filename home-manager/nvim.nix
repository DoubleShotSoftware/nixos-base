{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  # Get personalConfig - handle both NixOS and home-manager contexts
  personalConfig = config._module.args.personalConfig or config.personalConfig or {};
  users = personalConfig.users or {};

  # Determine username - in home-manager context, use config.home.username
  username = config.home.username or (if length (attrNames users) == 1 then head (attrNames users) else null);

  # Get user config
  userConfig = if username != null && users ? ${username} then users.${username} else {};

  # Check if nvim should be enabled for this user
  enableNvim = userConfig.nvim or false;

  # Get user's languages for nixcats
  userLanguages = userConfig.languages or [];

  # Whether this user has dotnet in their languages
  hasDotnet = builtins.elem "dotnet" userLanguages;

  # Build nixcats with user's languages
  nixcatsPackage =
    if pkgs ? mkNixCatsIDE then
      pkgs.mkNixCatsIDE { languages = userLanguages; }
    else
      null;

  # dotnet SDK for tool install (from overlay)
  dotnetSDK = pkgs.dotnetSDK or pkgs.unstable.dotnet-sdk;

in
{
  config = mkMerge [
    (mkIf (enableNvim && nixcatsPackage != null) {
      home.packages = [ nixcatsPackage ];

      # Set EDITOR environment variable globally
      home.sessionVariables = {
        EDITOR = "nvim";
        VISUAL = "nvim";
      };

      # Add shell aliases for all shells
      # Note: Individual shell modules should not override these
      programs.bash.shellAliases = mkIf (config.programs.bash.enable or false) {
        e = "nvim";
      };

      programs.zsh.shellAliases = mkIf (config.programs.zsh.enable or false) {
        e = "nvim";
      };

      programs.fish.shellAliases = mkIf (config.programs.fish.enable or false) {
        e = "nvim";
      };
    })

    # easy-dotnet-server: installed and updated via dotnet tool
    (mkIf (enableNvim && hasDotnet) {
      home.sessionVariables = {
        DOTNET_ROOT = "${dotnetSDK}/share/dotnet";
      };

      systemd.user.services.easy-dotnet-update = {
        Unit = {
          Description = "Install/update EasyDotnet global tool";
        };
        Service = {
          Type = "oneshot";
          Environment = [
            "PATH=${dotnetSDK}/bin:${pkgs.coreutils}/bin"
            "DOTNET_ROOT=${dotnetSDK}/share/dotnet"
            "DOTNET_CLI_TELEMETRY_OPTOUT=1"
            "HOME=%h"
          ];
          ExecStart = "${dotnetSDK}/bin/dotnet tool update -g EasyDotnet";
        };
      };

      systemd.user.timers.easy-dotnet-update = {
        Unit = {
          Description = "Periodically update EasyDotnet global tool";
        };
        Timer = {
          OnCalendar = "daily";
          OnStartupSec = "30s";
          Persistent = true;
        };
        Install = {
          WantedBy = [ "timers.target" ];
        };
      };
    })
  ];
}

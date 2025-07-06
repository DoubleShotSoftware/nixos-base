{
  config,
  lib,
  pkgs,
  inputs,
  desktop,
  ...
}:
with lib;
with builtins;
let
  users = config.personalConfig.users;
in
{
  config = mkMerge [
    {
      home-manager.users = mapAttrs (
        user: userConfig:
        if (userConfig.zellij && userConfig.userType == "normal") then
          trace "Enabling zellij for user: ${user}" {
            programs.zellij = {
              enable = true;
              attachExistingSession = true;
              settings = {
                theme = "catppuccin-mocha";
                keybindings = {
                };
              };
            };
          }
        else
          { }
      ) (filterAttrs (user: userConfig: userConfig.userType != "system") users);
    }
    (lib.mkIf (pkgs.system == "aarch64-darwin") {
      home-manager.users = mapAttrs (user: userConfig: {
        home.sessionPath = [ "/opt/homebrew/bin/" ];
      }) users;
    })
  ];
}

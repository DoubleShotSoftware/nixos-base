{ config, lib, pkgs, modulesPath, ... }:
with lib;
with builtins;
let users = config.personalConfig.users;
in
{
  config = mkMerge [
    (lib.mkIf (pkgs.system != "aarch64-darwin")
      {
        home-manager.users = mapAttrs
          (user: userConfig:
            if (userConfig.wezterm) then
              trace ''Enabling wezterm for ${user}''
                {
                  programs.wezterm = {
                    enable = true;
                    extraConfig = (builtins.readFile ./wezterm.lua);
                  };
                } else
              { })
          (filterAttrs (user: userConfig: userConfig.userType != "system") users);
      })
    (lib.mkIf (pkgs.system == "aarch64-darwin") {
      home-manager.users = mapAttrs
        (user: userConfig:
          if (userConfig.wezterm) then {
            xdg.configFile."wezterm/wezterm.lua" = { source = ./wezterm.lua; };
          } else
            { })
        users;
    })
  ];
}

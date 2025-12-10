{ config, lib, pkgs, ... }:
with lib;
with builtins;
let
  users = config.personalConfig.users;

  # Generate ghostty config for a user
  mkGhosttyConfig = user: userConfig: ''
    font-family = VictorMono Nerd Font Mono
    font-size = 16
    theme = catppuccin-mocha
    shell-integration = ${userConfig.shell}
    background-opacity = 0.85
    background-blur = false
    window-decoration = none
    keybind = shift+enter=text:\n
  '';
in {
  config = {
    home-manager.users = mapAttrs (user: userConfig:
      if (userConfig.ghostty) then
        trace "Enabling ghostty for ${user}" {
          home.packages = [ pkgs.ghostty ];
          home.file.".config/ghostty/config".text = mkGhosttyConfig user userConfig;
        }
      else {})
      (filterAttrs (user: userConfig: userConfig.userType != "system") users);
  };
}
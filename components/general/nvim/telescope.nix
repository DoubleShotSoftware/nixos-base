{ config, lib, options, pkgs, ... }:
with builtins;
with lib;
let
  users = config.personalConfig.users;
  desktopEnabled = any (userConfig: userConfig.desktop != "disabled")
    (mapAttrsToList (user: userConfig: userConfig) users);
  desktopPackages = if desktopEnabled then with pkgs; [ chafa imagemagick poppler_utils fontpreview ] else [];
  mkUserNvimConfig = user: {
    programs.neovim = {
      plugins = with pkgs.unstable.vimPlugins; [
        telescope-nvim
        telescope-fzf-native-nvim
        telescope-media-files-nvim
      ];
      extraPackages = with pkgs; [ fzf ] ;

    };
  };
  nvim_configs = mapAttrs (user: config:
    if (config.nvim) then
      (trace "Enabling nvim:telescope for user: ${user}" mkUserNvimConfig user)
    else
      { }) (filterAttrs (user: userConfig: userConfig.userType != "system")
        config.personalConfig.users);
in { config = { home-manager.users = nvim_configs; }; }

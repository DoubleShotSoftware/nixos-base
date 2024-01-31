{ config, lib, options, pkgs, ... }:
with builtins;
with lib;
let
  mkUserNvimConfig = user: {
    programs.neovim = {
      plugins = with pkgs.unstable.vimPlugins; [
        telescope-nvim
        telescope-fzf-native-nvim
        telescope-media-files-nvim
      ];
      extraPackages = with pkgs; [
        fzf
        chafa
        imagemagick
        poppler_utils
      ];
    };
  };
  nvim_configs = mapAttrs (user: config:
    if (config.nvim) then
      (trace "Enabling nvim:telescope for user: ${user}" mkUserNvimConfig user)
    else
      { }) (filterAttrs (user: userConfig: userConfig.userType != "system")
        config.personalConfig.users);
in { config = { home-manager.users = nvim_configs; }; }

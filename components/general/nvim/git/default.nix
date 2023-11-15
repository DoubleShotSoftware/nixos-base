{ config, lib, options, pkgs, ... }:
with builtins;
with lib;
let
  mkUserNvimConfig = user: {
    xdg.configFile = {
      "nvim/lua/git/init.lua".source = ./init.lua;
      "nvim/lua/git/config_gitsigns.lua".source = ./config_gitsigns.lua;
    };
    programs.neovim = {
      plugins = with pkgs.unstable.vimPlugins; [
        vim-fugitive
        gitsigns-nvim
        vim-rhubarb
      ];
      extraPackages = with pkgs; [ git ];
    };
  };
  nvim_configs = mapAttrs (user: config:
    if (config.nvim) then
      (trace "Enabling nvim for user: ${user}" mkUserNvimConfig user)
    else
      { }) (filterAttrs (user: userConfig: userConfig.userType != "system")
        config.personalConfig.users);
in { config = { home-manager.users = nvim_configs; }; }

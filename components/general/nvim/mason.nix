{ config, lib, options, pkgs, ... }:
with builtins;
with lib;
let
  mkUserNvimConfig = user: {
    programs.neovim = {
      plugins = with pkgs.unstable.vimPlugins; [
        { plugin = mason-nvim; }
        { plugin = mason-lspconfig-nvim; }
        { plugin = mason-tool-installer-nvim; }
      ];
      extraPackages = with pkgs; [ curl wget unzip git gnutar p7zip ];
    };
  };
  nvim_configs = mapAttrs (user: config:
    if (config.nvim) then
      (trace "Enabling nvim for user: ${user}" mkUserNvimConfig user)
    else
      { }) (filterAttrs (user: userConfig: userConfig.userType != "system")
        config.personalConfig.users);
in { config = { home-manager.users = nvim_configs; }; }

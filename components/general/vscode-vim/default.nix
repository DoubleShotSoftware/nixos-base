{ config, lib, pkgs, ... }:
with lib;
let
  personalConfig = config._module.args.personalConfig or config.personalConfig or {};
  users = personalConfig.users or {};

  # Create vscode-nvim.lua configuration for users who have it enabled
  mkUserVSCodeVimConfig = user: userConfig: {
    home.file.".config/vscode-nvim.lua".source = ./vscode-nvim.lua;
  };

  # Filter users who have both nvim and vscodeVimConfig enabled
  vscodeVimUsers = filterAttrs
    (user: userConfig:
      (userConfig.userType or "system") != "system" &&
      (userConfig.nvim or false) &&
      (userConfig.vscodeVimConfig or false))
    users;

  vscodeVimConfigs = mapAttrs mkUserVSCodeVimConfig vscodeVimUsers;

in {
  config = mkIf ((length (attrNames vscodeVimUsers)) > 0) {
    home-manager.users = vscodeVimConfigs;
  };
}

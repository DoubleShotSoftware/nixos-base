{ config, lib, options, pkgs, ... }:
with lib;
with builtins;
let
  pythonPackages = with pkgs; [
    black
    pipenv
    python311Full
    python311Packages.pip
  ];
  users = config.personalConfig.users;
  pythonDevelopers = mapAttrs (user: config:
    trace "Enabling python development for user: ${user}" {
      home = { packages = pythonPackages; };
      programs = {
        zsh = {
          oh-my-zsh = { plugins = [ "python" "pylint" "pyenv" "poetry" ]; };
        };
      };
    }) (filterAttrs (user: userConfig:
      (any (language: language == "python") userConfig.languages)) users);
  pythonNVIMDevelopers = mapAttrs (user: config:
    trace "Enabling python nvim development support for user: ${user}" (let
      inherit pythonPackages;
      lspPackages = with pkgs; [
        black
        python311Packages.flake8
        mypy
        nodePackages.pyright
      ];
    in {
      home = { packages = lspPackages; };
      xdg.configFile = {
        "nvim/lua/lsp/settings/python.lua".source = ./python.lua;
      };
      programs = { neovim = { extraPackages = pythonPackages; }; };
    })) (filterAttrs (user: userConfig:
      ((any (language: language == "python") userConfig.languages)
        && userConfig.nvim)) users);
in {
  config = lib.mkMerge [
    { home-manager.users = pythonDevelopers; }
    { home-manager.users = pythonNVIMDevelopers; }
  ];
}

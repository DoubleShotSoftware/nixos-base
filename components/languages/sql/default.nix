{ config, lib, options, pkgs, ... }:
with builtins;
with lib;
let
  users = config.personalConfig.users;
  postgresPackages = with pkgs; [ ];
  postgresDeveloper = mapAttrs
    (user: config: trace "Enabling postgres development for user: ${user}" { })
    (filterAttrs (user: userConfig:
      (any (language: language == "postgres") userConfig.languages)) users);
  postgresNVIMDevelopers = mapAttrs (user: config:
    trace "Enabling postgres nvim development support for user: ${user}" (let
      inherit postgresPackages;
      lspPackages = with pkgs.unstable; [ sqls ];
    in {
      home = {
        packages = lspPackages;
        file = { };
      };
      xdg.configFile = {
        "nvim/lua/user/lsp/settings/postgres.lua".source = ./postgres.lua;
        "nvim/lua/lsp/user/treesitter/postgres.lua".source = ./treesitter.lua;
        "nvim/lua/user/lsp/settings/postgrespths.lua".text = ''
          local M = {
              SQLS = "${pkgs.sqls}/bin/sqls",
          }
          return M
        '';
      };
      programs.neovim = {
        plugins = with pkgs.vimPlugins; [ cmp-npm ];
        extraPackages = with pkgs; [ tree-sitter-grammars.tree-sitter-sql ];
      };

    })) (filterAttrs (user: userConfig:
      ((any (language: language == "postgres") userConfig.languages)
        && userConfig.nvim)) users);
in {
  config = lib.mkMerge [
    { home-manager.users = postgresDeveloper; }
    { home-manager.users = postgresNVIMDevelopers; }
  ];
}

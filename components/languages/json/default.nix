{ config, lib, options, pkgs, ... }:
with lib;
with builtins;
let
  users = config.personalConfig.users;
  jsonPackages = with pkgs; [ jq ];
  jsonDeveloper = mapAttrs (user: config:
    trace "Enabling json development for user: ${user}" {
      home = { packages = jsonPackages; };
      systemd.user = { };
      programs.zsh = {
        oh-my-zsh = { plugins = [ "jsontools" ]; };

      };
    }) (filterAttrs (user: userConfig:
      (any (language: language == "json") userConfig.languages)) users);
  jsonNVIMDevelopers = mapAttrs (user: config: {
    home = {
      packages = jsonPackages;
      file = { };
    };
    xdg.configFile = {
      "nvim/lua/user/lsp/settings/json.lua".source = ./json.lua;
      "nvim/lua/lsp/user/treesitter/json.lua".source = ./treesitter.lua;
    };
    programs.neovim = {
      plugins = with pkgs.vimPlugins; [
        SchemaStore-nvim
      ];
      extraPackages = with pkgs; [
        jq
        tree-sitter-grammars.tree-sitter-json
        nodePackages.vscode-langservers-extracted
      ];
    };

  }) (filterAttrs (user: userConfig:
    ((any (language: language == "json") userConfig.languages)
      && userConfig.nvim)) users);
in {
  config = lib.mkMerge [
    { home-manager.users = jsonDeveloper; }
    { home-manager.users = jsonNVIMDevelopers; }
  ];
}

{ config, lib, options, pkgs, ... }:
with lib;
with builtins;
let
  users = config.personalConfig.users;
  typescriptPackages = with pkgs; [
    nodejs
    yarn
    nodePackages.npm
    nodePackages.typescript
    nodePackages.vscode-langservers-extracted
    nodePackages.typescript-language-server
  ];
  typescriptDeveloper = mapAttrs (user: config:
    trace "Enabling typescript development for user: ${user}" {
      home = {
        packages = typescriptPackages;
      };
      systemd.user = { };
      programs.zsh = {
        initExtra = ''
            if [ ! -f $HOME/.npm-global ];
            then
                mkdir -p $HOME/.npm-global
            fi
            set prefix '$HOME/.npm-global' || true
        '';
        oh-my-zsh = { plugins = [ "npm" "node" "yarn" ]; };

      };
    }) (filterAttrs (user: userConfig:
      (any (language: language == "typescript") userConfig.languages)) users);
  typescriptNVIMDevelopers = mapAttrs (user: config:
    trace "Enabling typescript nvim development support for user: ${user}" (let
      inherit typescriptPackages;
      lspPackages = with pkgs.unstable; [ ];
    in {
      home = {
        packages = lspPackages;
        file = { };
      };
      xdg.configFile = {
        "nvim/lua/user/lsp/settings/typescript.lua".source = ./typescript.lua;
        "nvim/lua/lsp/user/treesitter/typescript.lua".source = ./treesitter.lua;
      };
      programs.neovim = {
        plugins = with pkgs.vimPlugins; [  ];
        extraPackages = with pkgs; [
          tree-sitter-grammars.tree-sitter-tsx
          tree-sitter-grammars.tree-sitter-typescript
          tree-sitter-grammars.tree-sitter-javascript
        ];
      };

    })) (filterAttrs (user: userConfig:
      ((any (language: language == "typescript") userConfig.languages)
        && userConfig.nvim)) users);
in {
  config = lib.mkMerge [
    { home-manager.users = typescriptDeveloper; }
    { home-manager.users = typescriptNVIMDevelopers; }
  ];
}

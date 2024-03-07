{ config, lib, options, pkgs, ... }:
with lib;
with builtins;
let
  users = config.personalConfig.users;
  cmp-npm = pkgs.vimUtils.buildVimPlugin {
    pname = "cmp-npm";
    version = "2023-06-12";
    src = pkgs.fetchFromGitHub {
      owner = "David-Kunz";
      repo = "cmp-npm";
      rev = "2337f109f51a09297596dd6b538b70ccba92b4e4";
      sha256 = "sha256-6o0eO4uuHNBbo6pqWgRtleOxd8rYaYbrl+dTjhB6M8Q=";
    };
    meta.homepage = "https://github.com/David-Kunz/cmp-npm";
  };
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
        plugins = with pkgs.vimPlugins; [ cmp-npm ];
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

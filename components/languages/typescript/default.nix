{ config, lib, options, pkgs, ... }:
with lib;
with builtins;
let
  users = config.personalConfig.users;
  typescriptPackages = with pkgs; [
    nodejs
    yarn
    pnpm
    nodePackages.npm
    nodePackages.typescript
    pnpm
    corepack 
    nodePackages.prettier
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
      # TypeScript developers often want these additional ignore patterns
      # These will be merged with the user's git.exclude patterns
      programs.git = {
        extraConfig = {
          # Additional TypeScript/Node.js specific patterns can be configured here
          # The user's git.exclude patterns from personalConfig will still apply
        };
      };
    }) (filterAttrs (user: userConfig:
      (any (language: language == "typescript") userConfig.languages)) users);
in {
  config = lib.mkMerge [
    { home-manager.users = typescriptDeveloper; }
  ];
}

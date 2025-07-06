# TypeScript language configuration function
{ pkgs }:
{
  packages = with pkgs; [
    nodejs
    yarn
    pnpm
    nodePackages.npm
    nodePackages.typescript
    corepack
    nodePackages.prettier
  ];
  sessionVariables = {};
  shellPlugins = {
    zsh = [ "npm" "node" "yarn" ];
    fish = [];  # TODO: Add fish node/npm plugins
    bash = [];  # TODO: Add bash node/npm completions
  };
  shellInitExtra = {
    zsh = ''
      if [ ! -f $HOME/.npm-global ];
      then
          mkdir -p $HOME/.npm-global
      fi
      npm config set prefix '$HOME/.npm-global' 2>/dev/null || true
    '';
    fish = ''
      if not test -d $HOME/.npm-global
          mkdir -p $HOME/.npm-global
      end
      npm config set prefix '$HOME/.npm-global' 2>/dev/null || true
    '';
    bash = ''
      if [ ! -f $HOME/.npm-global ];
      then
          mkdir -p $HOME/.npm-global
      fi
      npm config set prefix '$HOME/.npm-global' 2>/dev/null || true
    '';
  };
  permittedInsecurePackages = [];
}
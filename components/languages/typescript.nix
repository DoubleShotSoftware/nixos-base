# TypeScript language configuration function
{ pkgs, username }:
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
      if [ ! -d /home/${username}/.npm-global ];
      then
          mkdir -p /home/${username}/.npm-global
      fi
      npm config set prefix /home/${username}/.npm-global 2>/dev/null || true
    '';
    fish = ''
      if not test -d /home/${username}/.npm-global
          mkdir -p /home/${username}/.npm-global
      end
      npm config set prefix /home/${username}/.npm-global 2>/dev/null || true
    '';
    bash = ''
      if [ ! -d /home/${username}/.npm-global ];
      then
          mkdir -p /home/${username}/.npm-global
      fi
      npm config set prefix /home/${username}/.npm-global 2>/dev/null || true
    '';
  };
  permittedInsecurePackages = [];
}

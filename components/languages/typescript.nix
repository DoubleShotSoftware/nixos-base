# TypeScript language configuration function
{ pkgs, username, lib, settings ? {} }:
let
  # nodejs is required — either the user-supplied package or a sensible default.
  # npm ships inside the nodejs derivation, so no separate npm package.
  nodejsPkg = if (settings.nodePackage or null) != null
    then lib.hiPrio settings.nodePackage
    else pkgs.nodejs;
  extraPackages = settings.extraPackages or [];
in
{
  packages = with pkgs; [
    nodejsPkg
    yarn
    pnpm
    typescript
    prettier
  ] ++ extraPackages;
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

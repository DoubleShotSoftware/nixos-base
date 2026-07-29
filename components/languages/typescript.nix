# TypeScript language configuration function
{ pkgs, username, lib, settings ? {} }:
let
  # nodejs is required — either the user-supplied package or a sensible default.
  # npm ships inside the nodejs derivation, so no separate npm package.
  nodejsPkg = if (settings.nodePackage or null) != null
    then lib.hiPrio settings.nodePackage
    else pkgs.nodejs;
  extraPackages = settings.extraPackages or [];

  # Opt-in weekly cleanup of stale node_modules (see models/languageSettings.nix).
  prune = settings.pruneStale or false;
  pruneDays = toString (settings.pruneStaleDays or 7);
  pruneRoot = settings.pruneRoot or "$HOME/dev";
  pruneScript = pkgs.writeScript "ts-prune-stale-node-modules" ''
    #!/usr/bin/env bash
    set -euo pipefail
    root="${pruneRoot}"
    [ -d "$root" ] || exit 0
    ${pkgs.findutils}/bin/find "$root" -type d -name node_modules -prune -mtime +${pruneDays} \
      -exec ${pkgs.coreutils}/bin/rm -rf {} +
  '';
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
  homeManager = if prune then {
    systemd.user.services.prune-stale-node-modules = {
      Unit.Description = "Prune stale node_modules under ${pruneRoot} (older than ${pruneDays} days)";
      Service = {
        Type = "oneshot";
        ExecStart = "${pruneScript}";
      };
    };
    systemd.user.timers.prune-stale-node-modules = {
      Unit.Description = "Weekly prune of stale node_modules";
      Timer = {
        OnCalendar = "weekly";
        Persistent = true;
      };
      Install.WantedBy = [ "timers.target" ];
    };
  } else {};
}

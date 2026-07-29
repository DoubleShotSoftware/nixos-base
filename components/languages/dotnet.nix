# Dotnet language configuration function
{ pkgs, username, lib ? null, settings ? {} }:
let
  # Opt-in weekly cleanup of stale build artifacts (see models/languageSettings.nix).
  # Removes bin/obj dirs that belong to a project (sibling .csproj/.fsproj/.vbproj/.sln)
  # and clears all NuGet local caches.
  prune = settings.pruneStale or false;
  pruneDays = toString (settings.pruneStaleDays or 7);
  pruneRoot = settings.pruneRoot or "$HOME/dev";
  roslynUpdate = settings.roslynAutoUpdate or false;
  pruneScript = pkgs.writeScript "dotnet-prune-stale-artifacts" ''
    #!/usr/bin/env bash
    set -euo pipefail
    root="${pruneRoot}"
    days=${pruneDays}
    if [ -d "$root" ]; then
      ${pkgs.findutils}/bin/find "$root" -type d \( -name bin -o -name obj \) -prune -mtime +"$days" -print0 \
        | while IFS= read -r -d "" d; do
            parent=$(${pkgs.coreutils}/bin/dirname "$d")
            if ${pkgs.coreutils}/bin/ls "$parent"/*.csproj "$parent"/*.fsproj "$parent"/*.vbproj "$parent"/*.sln >/dev/null 2>&1; then
              ${pkgs.coreutils}/bin/rm -rf "$d"
            fi
          done
    fi
    # Clear all NuGet local caches (global-packages, http-cache, temp, plugins-cache)
    ${pkgs.dotnetSDK}/bin/dotnet nuget locals all --clear
  '';
  # easy-dotnet's C# LSP is the roslyn-language-server dotnet global tool, installed
  # --prerelease into ~/.dotnet/tools; it never self-updates. Pull the latest preview,
  # then softly restart running servers so the new build takes over.
  roslynUpdateScript = pkgs.writeScript "dotnet-roslyn-update" ''
    #!/usr/bin/env bash
    # Not -e: a missing tool or no running server must not fail the unit.
    set -uo pipefail
    export DOTNET_CLI_TELEMETRY_OPTOUT=1 DOTNET_NOLOGO=1
    dotnet="${pkgs.dotnetSDK}/bin/dotnet"
    "$dotnet" tool update --global roslyn-language-server --prerelease \
      || "$dotnet" tool install --global roslyn-language-server --prerelease \
      || true
    # SIGTERM the stdio servers (comm truncates to "roslyn-language", so match the
    # full cmdline); nvim's easy-dotnet respawns them against the fresh build.
    ${pkgs.procps}/bin/pkill -TERM -f "roslyn-language-server --stdio" || true
  '';

  pruneUnits =
    if prune then {
      services.prune-stale-dotnet = {
        Unit.Description = "Prune stale dotnet bin/obj under ${pruneRoot} (older than ${pruneDays} days) and clear NuGet caches";
        Service = {
          Type = "oneshot";
          ExecStart = "${pruneScript}";
        };
      };
      timers.prune-stale-dotnet = {
        Unit.Description = "Weekly prune of stale dotnet build artifacts";
        Timer = {
          OnCalendar = "weekly";
          Persistent = true;
        };
        Install.WantedBy = [ "timers.target" ];
      };
    } else { services = {}; timers = {}; };

  roslynUnits =
    if roslynUpdate then {
      services.roslyn-update = {
        Unit.Description = "Update prerelease roslyn-language-server tool and softly restart running instances";
        Service = {
          Type = "oneshot";
          ExecStart = "${roslynUpdateScript}";
        };
      };
      timers.roslyn-update = {
        Unit.Description = "Weekly update of the roslyn-language-server dotnet global tool";
        Timer = {
          OnCalendar = "weekly";
          Persistent = true;
        };
        Install.WantedBy = [ "timers.target" ];
      };
    } else { services = {}; timers = {}; };
in
{
  packages = with pkgs; [
    dotnetPackages.Nuget
    dotnetPackages.NUnit
    dotnetSDK
    resharper-cli
  ];
  sessionVariables = {
    DOTNET_ROOT = "${pkgs.dotnetSDK}/share/dotnet";
    DOTNET_CLI_TELEMETRY_OPTOUT = "1";
    PATH = "${pkgs.dotnetSDK}/bin:$HOME/.dotnet/tools:$HOME/.bin:$PATH";
    DOTNET_NOLOGO = "true";
    DOTNET_ADD_GLOBAL_TOOLS_TO_PATH = "true";
    DOTNET_HOST_PATH = "${pkgs.dotnetSDK}/bin/dotnet";
  };
  shellPlugins = {
    zsh = [ "dotnet" ];
    fish = [ ]; # TODO: Add fish dotnet completions if available
    bash = [ ]; # TODO: Add bash dotnet completions if available
  };
  shellInitExtra = {
    zsh = "";
    fish = "";
    bash = "";
  };
  permittedInsecurePackages = [
    "dotnet-sdk-6.0.136"
    "dotnet-sdk-7.0.317"
    "dotnetCorePackages.sdk_7_0_3xx"
  ];
  homeManager = {
    systemd.user.services = pruneUnits.services // roslynUnits.services;
    systemd.user.timers = pruneUnits.timers // roslynUnits.timers;
  };
}

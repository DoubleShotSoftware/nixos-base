# Language-specific settings for components/languages/*
{ lib }:
with lib;
let
  # Shared opt-in stale-artifact pruning (consumed by components/languages/*.nix).
  # Off by default; when enabled it installs a weekly systemd user timer that
  # rm -rf's build artifacts older than pruneStaleDays under pruneRoot.
  pruneOptions = {
    pruneStale = mkOption {
      type = types.bool;
      default = false;
      description = "Weekly systemd user timer that removes stale build artifacts older than pruneStaleDays under pruneRoot.";
    };
    pruneStaleDays = mkOption {
      type = types.ints.positive;
      default = 7;
      description = "Age threshold in days for the stale-artifact pruner.";
    };
    pruneRoot = mkOption {
      type = types.str;
      default = "$HOME/dev";
      description = "Root directory the stale-artifact pruner scans (shell-expanded at runtime).";
    };
  };
in
{
  options = {
    typescript = mkOption {
      type = types.submodule {
        options = {
          nodePackage = mkOption {
            type = types.nullOr types.package;
            default = null;
            description = "Node.js package to use. Defaults to pkgs.unstable.nodejs if null.";
          };
          extraPackages = mkOption {
            type = types.listOf types.package;
            default = [];
            description = "Additional packages to include with typescript language.";
          };
        } // pruneOptions;
      };
      default = {};
      description = "TypeScript/Node.js language settings.";
    };

    dotnet = mkOption {
      type = types.submodule {
        options = pruneOptions // {
          roslynAutoUpdate = mkOption {
            type = types.bool;
            default = false;
            description = "Weekly systemd user timer that updates the prerelease roslyn-language-server dotnet global tool (easy-dotnet's C# LSP, which does not self-update) and softly restarts any running instances.";
          };
        };
      };
      default = {};
      description = "Dotnet language settings.";
    };

    # Placeholder for future languages - add as needed:
    # python = mkOption { ... };
    # rust = mkOption { ... };
  };
}

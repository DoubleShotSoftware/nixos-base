# Language-specific settings for components/languages/*
{ lib }:
with lib;
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
        };
      };
      default = {};
      description = "TypeScript/Node.js language settings.";
    };

    # Placeholder for future languages - add as needed:
    # dotnet = mkOption { ... };
    # python = mkOption { ... };
    # rust = mkOption { ... };
  };
}

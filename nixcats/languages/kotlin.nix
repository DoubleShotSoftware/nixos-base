# nixcats/languages/kotlin.nix - Kotlin language support
# Uses JetBrains official kotlin-lsp (packaged in packages/kotlin-lsp.nix)
{ pkgs, stablePkgs, ... }:
{
  lspsAndRuntimeDeps = with pkgs; [
    kotlin-lsp  # Custom package from overlay
    ktlint
    kotlin
    gradle
  ];

  startupPlugins = [ ];

  optionalPlugins = [ ];

  environmentVariables = { };
}

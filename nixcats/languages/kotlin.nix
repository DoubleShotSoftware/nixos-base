# nixcats/languages/kotlin.nix - Kotlin/JVM language support
{ pkgs, ... }:
let kotlinLspPkg = pkgs."kotlin-lsp";
in
{
  lspsAndRuntimeDeps = with pkgs; [
    kotlinLspPkg
    jdk17_headless
    gradle
    maven
    kotlin
    ktlint
  ];

  startupPlugins = [ ];

  optionalPlugins = [ ];

  extra = {
    kotlinLspBinary = "${kotlinLspPkg}/bin/kotlin-lsp";
  };
}

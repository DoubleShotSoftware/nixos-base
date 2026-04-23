# nixcats/languages/kotlin.nix - Kotlin/JVM language support
{ pkgs, stablePkgs, ... }:
{
  lspsAndRuntimeDeps = with pkgs; [
    kotlin-lsp
    jdk17_headless
    gradle
    maven
    kotlin
    ktlint
  ];

  startupPlugins = [ ];

  optionalPlugins = [ ];

  environmentVariables = {
    JAVA_HOME = "${pkgs.jdk17_headless}";
    JDK_HOME = "${pkgs.jdk17_headless}";
  };

  extra = {
    kotlinLspBinary = "${pkgs.kotlin-lsp}/bin/kotlin-lsp";
  };
}

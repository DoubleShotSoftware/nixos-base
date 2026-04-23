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

  environmentVariables = {
    JAVA_HOME = "${pkgs.jdk17_headless}";
    JDK_HOME = "${pkgs.jdk17_headless}";
  };

  extra = {
    kotlinLspBinary = "${kotlinLspPkg}/bin/kotlin-lsp";
  };
}

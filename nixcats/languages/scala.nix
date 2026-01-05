# nixcats/languages/scala.nix - Scala language support
{ pkgs, stablePkgs, ... }:
{
  lspsAndRuntimeDeps = with pkgs; [
    metals
    mill
    sbt
    scalafmt
  ];

  startupPlugins = with pkgs.vimPlugins; [
    nvim-metals
  ];

  optionalPlugins = [ ];

  environmentVariables = { };
}

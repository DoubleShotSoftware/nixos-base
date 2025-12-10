# nixcats/languages/sql.nix - SQL language support
{ pkgs, stablePkgs, ... }:
{
  lspsAndRuntimeDeps = with pkgs; [
    sqls
    pgformatter
  ];

  startupPlugins = [ ];

  optionalPlugins = [ ];

  environmentVariables = { };
}

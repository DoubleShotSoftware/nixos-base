# SQL language configuration function
{ pkgs }:
{
  packages = with pkgs; [
    postgresql
    pgformatter
  ];
  sessionVariables = {};
  shellPlugins = {
    zsh = [];  # No specific zsh plugins for SQL
    fish = [];  # No specific fish plugins for SQL
    bash = [];  # No specific bash plugins for SQL
  };
  shellInitExtra = {
    zsh = "";
    fish = "";
    bash = "";
  };
  permittedInsecurePackages = [];
}
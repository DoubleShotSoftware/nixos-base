# JSON language configuration function
{ pkgs, username, lib ? null, settings ? {} }:
{
  packages = with pkgs; [ unstable.jq ];
  sessionVariables = {};
  shellPlugins = {
    zsh = [ "jsontools" ];
    fish = [];  # No specific fish plugins for JSON
    bash = [];  # No specific bash plugins for JSON
  };
  shellInitExtra = {
    zsh = "";
    fish = "";
    bash = "";
  };
  permittedInsecurePackages = [];
}

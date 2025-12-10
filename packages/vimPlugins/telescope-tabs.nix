# packages/vimPlugins/telescope-tabs.nix
# Telescope extension for tab management (LukasPietzschmann/telescope-tabs)
{ pkgs }:
let
  version = "777b1f630f3d6a12a2e71635a82581c988d6da2e";
in pkgs.vimUtils.buildVimPlugin {
  inherit version;
  name = "telescope-tabs";
  src = pkgs.fetchFromGitHub {
    owner = "LukasPietzschmann";
    repo = "telescope-tabs";
    rev = version;
    hash = "sha256-5NpH9+0ECrcKi8quPLpCHLSPTuzGETWtq4E+2jqUKio=";
  };
}

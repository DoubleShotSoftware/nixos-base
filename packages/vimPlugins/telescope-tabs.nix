# packages/vimPlugins/telescope-tabs.nix
# Telescope extension for tab management (LukasPietzschmann/telescope-tabs)
{ pkgs }:
let
  version = "9ca0800d4e9c2610d5cac4d121cde0d9fbd89a64";
in pkgs.vimUtils.buildVimPlugin {
  inherit version;
  name = "telescope-tabs";
  src = pkgs.fetchFromGitHub {
    owner = "LukasPietzschmann";
    repo = "telescope-tabs";
    rev = version;
    hash = "sha256-++iTyrjl6IX2GmwljbgcwiYvZ3ghsX732VWMcyu1ciw=";
  };
}

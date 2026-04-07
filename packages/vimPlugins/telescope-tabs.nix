# packages/vimPlugins/telescope-tabs.nix
# Telescope extension for tab management (LukasPietzschmann/telescope-tabs)
{pkgs}: let
  version = "62c127346c04c698c0cbd1c1ba945609a0ad10db";
in
  pkgs.vimUtils.buildVimPlugin {
    inherit version;
    name = "telescope-tabs";
    src = pkgs.fetchFromGitHub {
      owner = "LukasPietzschmann";
      repo = "telescope-tabs";
      rev = version;
      hash = "sha256-WIuY25GFqhVV5kD/2BYA1f5qniS0xQJ9iM2/2+6N2Iw=";
    };
    dependencies = with pkgs; [vimPlugins.telescope-nvim];
    nvimRequireCheck = "telescope";
  }

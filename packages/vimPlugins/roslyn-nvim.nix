# packages/vimPlugins/roslyn-nvim.nix
# Roslyn LSP integration for Neovim (seblyng/roslyn.nvim)
{ pkgs }:
let
  version = "1ebc9393d3e577d9f68102f14d98b2e4e7f15644";
in pkgs.vimUtils.buildVimPlugin {
  inherit version;
  name = "roslyn.nvim";
  src = pkgs.fetchFromGitHub {
    owner = "seblyng";
    repo = "roslyn.nvim";
    rev = version;
    hash = "sha256-sKlShvL8V8/jzVYQQ5UlEarIF9tBIN+JFe6msrPvb0k=";
  };
}

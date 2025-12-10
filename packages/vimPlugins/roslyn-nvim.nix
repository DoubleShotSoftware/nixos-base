# packages/vimPlugins/roslyn-nvim.nix
# Roslyn LSP integration for Neovim (seblyng/roslyn.nvim)
{ pkgs }:
let
  version = "14ff65704f2a1658f55646618d6520cf00b3f576";
in pkgs.vimUtils.buildVimPlugin {
  inherit version;
  name = "roslyn.nvim";
  src = pkgs.fetchFromGitHub {
    owner = "seblyng";
    repo = "roslyn.nvim";
    rev = version;
    hash = "sha256-e7yffLdeQEmfaSxkuaQVu3nJX/8inPRosX2K1dyNO/s=";
  };
}

# packages/vimPlugins/roslyn-nvim.nix
# Roslyn LSP integration for Neovim (seblyng/roslyn.nvim)
{ pkgs }:
let
  version = "f06e8c953c4091f790aabc05060cd923f31940fa";
in pkgs.vimUtils.buildVimPlugin {
  inherit version;
  name = "easy-dotnet.nvim";
  src = pkgs.fetchFromGitHub {
    owner = "GustavEikaas";
    repo = "easy-dotnet.nvim";
    rev = version;
    hash = "";
  };
}

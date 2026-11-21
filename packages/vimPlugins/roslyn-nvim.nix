# packages/vimPlugins/roslyn-nvim.nix
# Roslyn LSP integration for Neovim (seblyng/roslyn.nvim)
{ pkgs }:
let
  version = "ff43201090361b8936e008a006473b59ef2c0ca6";
in pkgs.vimUtils.buildVimPlugin {
  inherit version;
  name = "roslyn.nvim";
  src = pkgs.fetchFromGitHub {
    owner = "seblyng";
    repo = "roslyn.nvim";
    rev = version;
    hash = "sha256-NUzG2ulccKHxfv9v4hFStYgaNSZVm6vV5nOFTiFIP20=";
  };
}

# packages/vimPlugins/easy-dotnet.nix
# .NET development for Neovim (GustavEikaas/easy-dotnet.nvim)
{ pkgs }:
let
  version = "8f557b46d0954d216ce73c2f4ca7dcd04ff27b64";
in pkgs.vimUtils.buildVimPlugin {
  inherit version;
  name = "easy-dotnet.nvim";
  src = pkgs.fetchFromGitHub {
    owner = "GustavEikaas";
    repo = "easy-dotnet.nvim";
    rev = version;
    hash = "sha256-yeyQnJwnePmIiRR/7WGs1vc3amuuduTNkIcfLfIv364=";
  };
  # Modules have runtime deps (telescope, roslyn server) unavailable at build time
  doCheck = false;
}

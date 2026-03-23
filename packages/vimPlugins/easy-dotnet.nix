# packages/vimPlugins/easy-dotnet.nix
# .NET development for Neovim (GustavEikaas/easy-dotnet.nvim)
{ pkgs }:
let
  version = "29441d4c4f5e2e8337e8810b09e55763c5aa803d";
in pkgs.vimUtils.buildVimPlugin {
  inherit version;
  name = "easy-dotnet.nvim";
  src = pkgs.fetchFromGitHub {
    owner = "GustavEikaas";
    repo = "easy-dotnet.nvim";
    rev = version;
    hash = "sha256-5c7jWEQlq6EMM75Sbqt2q7djzZp4H4JZrdSl+oiEP8E=";
  };
}

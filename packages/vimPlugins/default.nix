# packages/vimPlugins/default.nix
# Custom vim plugins shared between nixvim and nixcats
{ pkgs }:
{
  roslyn-nvim = pkgs.callPackage ./roslyn-nvim.nix { };
  telescope-tabs = pkgs.callPackage ./telescope-tabs.nix { };
  easy-dotnet = pkgs.callPackage ./easy-dotnet.nix { };
  codediff = pkgs.callPackage ./vscode-diff.nix { };
}

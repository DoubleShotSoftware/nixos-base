# packages/vimPlugins/easy-dotnet.nix
# .NET development for Neovim (GustavEikaas/easy-dotnet.nvim)
#
# The repo has no release tags, so we track a known-good HEAD commit. This plugin
# is protocol-coupled to the `EasyDotnet` server NuGet built in
# ../easy-dotnet-tool.nix -- bump BOTH together. As of this commit the plugin no
# longer calls `msbuild/project-properties` and handles the newer server's
# notifications, matching server 3.2.x.
{ pkgs }:
let
  # HEAD of 25_11-era main, 2026-06-05 (no upstream tags exist).
  version = "4553feb3e82002ef4588b8e429d28cc5a6e19e5d";
in pkgs.vimUtils.buildVimPlugin {
  inherit version;
  name = "easy-dotnet.nvim";
  src = pkgs.fetchFromGitHub {
    owner = "GustavEikaas";
    repo = "easy-dotnet.nvim";
    rev = version;
    hash = "sha256-e+6/BJYFCBxiNe//tAjKXXtZ7B1EwA8u7RaEdMmnM5U=";
  };
  # Modules have runtime deps (telescope, roslyn server) unavailable at build time
  doCheck = false;
}

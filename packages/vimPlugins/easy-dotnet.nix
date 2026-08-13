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
  # HEAD of main, 2026-07-02 (no upstream tags exist).
  version = "07a41015af3bcbad7dff94191d5ad4b8a67fd202";
in pkgs.vimUtils.buildVimPlugin {
  inherit version;
  name = "easy-dotnet.nvim";
  src = pkgs.fetchFromGitHub {
    owner = "GustavEikaas";
    repo = "easy-dotnet.nvim";
    rev = version;
    hash = "sha256-/XQu9ywd4AK8sD7AIRdPJYjrPqM5ZorZv266tJViz/M=";
  };
  # Modules have runtime deps (telescope, roslyn server) unavailable at build time
  doCheck = false;
}

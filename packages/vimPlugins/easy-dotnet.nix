# packages/vimPlugins/easy-dotnet.nix
# .NET development for Neovim (GustavEikaas/easy-dotnet.nvim)
#
# The repo has no release tags, so we track a known-good HEAD commit. This plugin
# is protocol-coupled to the `EasyDotnet` server NuGet built in
# ../easy-dotnet-tool.nix -- bump BOTH together. Both pins live in
# ../easy-dotnet-pair.nix; this derivation asserts the (plugin, server) pair is a
# registered/verified combo, failing the build otherwise.
{ pkgs, lib }:
let
  pair = import ../easy-dotnet-pair.nix;
  version = pair.pluginRev;
in assert lib.assertMsg pair.isCurrentPairRegistered ''
  easy-dotnet drift: plugin commit ${pair.pluginRev} does not form a tested pair
  with server ${pair.serverVersion} (packages/easy-dotnet-pair.nix:knownPairs).
  The plugin and server are protocol-coupled -- bump and verify them together.
''; pkgs.vimUtils.buildVimPlugin {
  inherit version;
  name = "easy-dotnet.nvim";
  src = pkgs.fetchFromGitHub {
    owner = "GustavEikaas";
    repo = "easy-dotnet.nvim";
    rev = version;
    hash = pair.pluginHash;
  };
  # Modules have runtime deps (telescope, roslyn server) unavailable at build time
  doCheck = false;
}

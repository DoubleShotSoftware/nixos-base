# nixcats/languages/nix.nix - Nix language support
{ pkgs, stablePkgs, ... }:
{
  lspsAndRuntimeDeps = with pkgs; [
    nixd
    nil
    alejandra
    nixfmt-rfc-style
    statix
    deadnix
  ];

  startupPlugins = with pkgs.vimPlugins; [
    # none-ls for formatting
  ];

  optionalPlugins = [ ];

  environmentVariables = { };
}

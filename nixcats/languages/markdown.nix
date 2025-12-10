# nixcats/languages/markdown.nix - Markdown language support
# LSP: marksman, Plugin: render-markdown-nvim (configured in editor.lua)
{ pkgs, stablePkgs, ... }:
{
  lspsAndRuntimeDeps = with pkgs; [
    marksman          # Markdown LSP
    mdformat          # Markdown formatter
  ];

  startupPlugins = [ ];  # render-markdown-nvim is in general plugins

  optionalPlugins = [ ];

  environmentVariables = { };

  extra = { };
}

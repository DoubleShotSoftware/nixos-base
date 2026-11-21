# nixcats/languages/typescript.nix - TypeScript/JavaScript language support
{ pkgs, stablePkgs, ... }:
{
  lspsAndRuntimeDeps = with pkgs; [
    typescript
    typescript-language-server
    eslint
    vscode-langservers-extracted  # eslint, html, css LSPs (json LSP ships in general)
    # prettier ships in general lspsAndRuntimeDeps (used for json/yaml too)
    # nodejs provided by components/languages/typescript.nix in home.packages
  ];

  startupPlugins = with pkgs.vimPlugins; [
    # nvim-lspconfig handles ts_ls
  ];

  optionalPlugins = [ ];

  environmentVariables = { };
}

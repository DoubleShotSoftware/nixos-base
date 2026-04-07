# nixcats/languages/typescript.nix - TypeScript/JavaScript language support
{ pkgs, stablePkgs, ... }:
{
  lspsAndRuntimeDeps = with pkgs; [
    typescript
    typescript-language-server
    eslint
    vscode-langservers-extracted  # eslint, html, css, json LSPs
    prettier
    # nodejs provided by components/languages/typescript.nix in home.packages
  ];

  startupPlugins = with pkgs.vimPlugins; [
    # nvim-lspconfig handles ts_ls
  ];

  optionalPlugins = [ ];

  environmentVariables = { };
}

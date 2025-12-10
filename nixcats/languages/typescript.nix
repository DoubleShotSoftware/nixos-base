# nixcats/languages/typescript.nix - TypeScript/JavaScript language support
{ pkgs, stablePkgs, ... }:
{
  lspsAndRuntimeDeps = with pkgs; [
    typescript
    nodePackages.typescript-language-server
    nodePackages.eslint
    nodePackages.prettier
    # nodejs provided by components/languages/typescript.nix in home.packages
  ];

  startupPlugins = with pkgs.vimPlugins; [
    # nvim-lspconfig handles ts_ls
  ];

  optionalPlugins = [ ];

  environmentVariables = { };
}

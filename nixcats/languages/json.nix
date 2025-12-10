# nixcats/languages/json.nix - JSON language support
{ pkgs, stablePkgs, ... }:
{
  lspsAndRuntimeDeps = with pkgs; [
    nodePackages.vscode-json-languageserver
    jq
  ];

  startupPlugins = with pkgs.vimPlugins; [
    SchemaStore-nvim
  ];

  optionalPlugins = [ ];

  environmentVariables = { };
}

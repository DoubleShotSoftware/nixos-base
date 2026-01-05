# nixcats/languages/bash.nix - Bash/Shell language support
{ pkgs, stablePkgs, ... }:
{
  lspsAndRuntimeDeps = with pkgs; [
    nodePackages.bash-language-server
    shellcheck
    shfmt
  ];

  startupPlugins = [ ];

  optionalPlugins = [ ];

  environmentVariables = { };
}

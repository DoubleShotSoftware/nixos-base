# nixcats/languages/terraform.nix - Terraform/OpenTofu language support
{ pkgs, stablePkgs, ... }:
{
  lspsAndRuntimeDeps = with pkgs; [
    opentofu
    tofu-ls
    tflint
  ];

  startupPlugins = with pkgs.vimPlugins; [
    vim-terraform
  ];

  optionalPlugins = [ ];

  environmentVariables = { };
}

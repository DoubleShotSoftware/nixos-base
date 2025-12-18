# Terraform/OpenTofu language configuration function
{ pkgs, username, lib, settings ? {} }:
{
  packages = with pkgs; [
    opentofu
    opentofu-ls
  ];
  sessionVariables = {
  };
  shellPlugins = {
    zsh = [ "opentofu" ];
    fish = [ ]; # TODO: Add fish terraform completions if available
    bash = [ ]; # TODO: Add bash terraform completions if available
  };
  shellInitExtra = {
    zsh = "";
    fish = "";
    bash = "";
  };
  permittedInsecurePackages = [
  ];
}

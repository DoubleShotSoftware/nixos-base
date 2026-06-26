# AWS language configuration function
{ pkgs, username, lib, settings ? {} }:
{

  packages = with pkgs; [
    aws-mfa
    awscli2
    awsls
    awsume
  ];
  sessionVariables = {
  };
  shellPlugins = {
    zsh = [ "aws" ];
    fish = [ ]; # TODO: Add fish AWS completions if available
    bash = [ ]; # TODO: Add bash AWS completions if available
  };
  shellInitExtra = {
    zsh = "";
    fish = "";
    bash = "";
  };
  permittedInsecurePackages = [
  ];
}

# AWS language configuration function
{ pkgs, username }:
{

  packages = with pkgs; [
    aws-mfa
    aws-shell
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

# nixcats/languages/aws.nix - AWS/CloudFormation language support
{ pkgs, stablePkgs, ... }:
{
  lspsAndRuntimeDeps = with pkgs; [
    # CLI tools
    awscli2
    ssm-session-manager-plugin
    aws-sam-cli
    # CloudFormation/SAM validation
    python3Packages.cfn-lint
    # yaml-language-server ships in general lspsAndRuntimeDeps; the aws block
    # in plugins/lsp.lua layers CFN schemas on top of the base yamlls config.
  ];

  startupPlugins = [ ];

  optionalPlugins = [ ];

  environmentVariables = { };
}

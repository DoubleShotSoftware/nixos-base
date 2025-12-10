# Factory base constants configuration
# Defines paths and other constants that can be overridden
{ lib, ... }:
{
  options.factory.constants = {
    tokensPath = lib.mkOption {
      type = lib.types.str;
      default = "/etc/gitops/tokens.json";
      description = "Path where access tokens JSON is stored";
    };
    
    nixAccessTokensPath = lib.mkOption {
      type = lib.types.str;
      default = "/etc/nix/access-tokens.conf";
      description = "Path where Nix access tokens config is written";
    };
    
    gitCredentialsPath = lib.mkOption {
      type = lib.types.str;
      default = "/root/.git-credentials";
      description = "Path for git credentials file";
    };
  };
  
  config = {
    # Default values are set in options above
  };
}
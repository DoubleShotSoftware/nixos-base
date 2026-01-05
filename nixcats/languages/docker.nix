# nixcats/languages/docker.nix - Docker/Dockerfile language support
{ pkgs, stablePkgs, ... }:
{
  lspsAndRuntimeDeps = with pkgs; [
    dockerfile-language-server-nodejs
    docker-compose-language-service
    hadolint
  ];

  startupPlugins = [ ];

  optionalPlugins = [ ];

  environmentVariables = { };
}

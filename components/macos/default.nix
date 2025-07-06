{ config, lib, options, pkgs, ... }:

{
  imports = [ ./darwin-configuration.nix ./homebrew  ];
}

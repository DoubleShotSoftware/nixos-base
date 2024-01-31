{ config, lib, options, pkgs, ... }:

{
  imports = [ ./yabai ./darwin-configuration.nix ./homebrew  ];
}

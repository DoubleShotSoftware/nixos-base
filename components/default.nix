{ config, lib, options, pkgs, ... }:
{
  imports = [
    ./linux
    ./general
    ./base.nix
    ./languages
  ];
}


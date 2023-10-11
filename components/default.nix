{ config, lib, options, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    ruby
  ];
}


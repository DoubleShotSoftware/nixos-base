{ config, lib, options, pkgs, ... }:
{
  imports = [
    ./dotnet
    ./python
  ];
}

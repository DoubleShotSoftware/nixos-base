{ pkgs
, linuxKernel
, config
, buildPackages
, callPackage
, makeOverridable
, recurseIntoAttrs
, dontRecurseIntoAttrs
, stdenv
, stdenvNoCC
, newScope
, lib
, fetchurl
, gcc10Stdenv
, ...
}:
# https://github.com/NixOS/nixpkgs/blob/master/pkgs/top-level/linux-kernels.nix
with linuxKernel;
with lib;
{
    imports = [
        ./dotnet
    ];
}

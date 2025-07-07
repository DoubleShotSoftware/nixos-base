{ pkgs, ... }:

{
  resharper-cli = pkgs.callPackage ./resharper-cli.nix { };
}
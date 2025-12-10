# NixOS-level language configuration module
{ config, lib, pkgs, ... }:
let
  languages = import ./default.nix { inherit config lib pkgs; };
in {
  config = languages.nixosConfig;
}
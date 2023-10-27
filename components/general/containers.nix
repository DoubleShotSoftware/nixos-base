{ config, lib, pkgs, ... }:
let unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
in
{
  # https://nixos.org/manual/nixos/stable/index.html#sec-replace-modules
  environment.systemPackages = [
    unstable.podman
    unstable.podman-tui
    unstable.podman-unwrapped
    unstable.podman-compose
  ];
  virtualisation.oci-containers.backend = "podman";
  virtualisation.podman = {
    enable = true;
    dockerSocket.enable = true;
    dockerCompat = true;
    package = unstable.podman;
  };
}

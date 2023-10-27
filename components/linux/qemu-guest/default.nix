{ config, options, pkgs, ... }:
let unstable = import <nixos-unstable> { };
in {
  services = {
    qemuGuest.enable = true;
    spice-vdagentd.enable = true;
  };
}

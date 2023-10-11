{ config, lib, options, sops, pkgs, ... }:
with lib; {
  imports = [
    ./libvirt.nix
    ./containers.nix
    ./zfs.nix
    ./vfio.nix
    ./persist-network.nix
    ./linger.nix
    ./dnsmasq.nix
  ];
  config = mkMerge [{
    environment.systemPackages = with pkgs; [
      inetutils
      linux-firmware
      sof-firmware
      alsa-firmware
      pinentry
      pinentry-curses
    ];
    programs.gnupg = {
      agent = {
        pinentryFlavor = "curses";
        enable = true;
        enableSSHSupport = true;
      };
    };
  }];
}

{ config, lib, options, sops, pkgs, ... }:
with lib; {
  imports = [
    ./acme.nix
    ./containers.nix
    ./dnsmasq.nix
    ./qemu-guest
    ./immersedvr.nix
    ./libvirt.nix
    ./persist-network.nix
    ./pipewire.nix
    ./desktop
    ./linger.nix
    ./vm-guest.nix
    ./vfio.nix
    ./zfs.nix
    ./zrepl.nix
    ./usb-awake.nix
    ./fonts
    ./nix-builder.nix
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
        enable = true;
        enableSSHSupport = true;
      };
    };
  }];
}

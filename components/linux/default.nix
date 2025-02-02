{ config, lib, options, sops, pkgs, ... }:
with lib; {
  imports = [
    ./acme.nix
    ./containers.nix
    ./dnsmasq.nix
    ./qemu-guest
    # ./immersedvr.nix
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
  ];
  config = mkMerge [{
    environment.systemPackages = with pkgs; [
      inetutils
      jq  
    ];
    programs.gnupg = {
      agent = {
        enable = true;
        enableSSHSupport = true;
      };
    };
  }];
}

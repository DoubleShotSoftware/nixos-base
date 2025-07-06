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
    ./fonts
    ./nix-builder.nix
  ];
  config = mkMerge [{
    system.stateVersion = config.personalConfig.system.nixStateVersion;
    environment.systemPackages = with pkgs; [
      inetutils
      jq
      usbutils
      nfs-utils
      pciutils
      cryptsetup
      openssl
    ];
    programs.gnupg = {
      agent = {
        enable = true;
        enableSSHSupport = true;
      };
    };
    programs.nix-ld = {
      enable = true;
      libraries = with pkgs; [
        stdenv.cc.cc
        zlib
        fuse3
        icu
        nss
        openssl
        curl
        expat
        libgcc
        libllvm
      ];
    };
  }];
}

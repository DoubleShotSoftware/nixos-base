{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
{
  imports = [
    ./acme.nix
    ./cockpit.nix
    ./containers.nix
    ./device-type.nix
    ./dnsmasq.nix
    ./qemu-guest
    # ./immersedvr.nix
    ./chromium-headless
    ./libvirt.nix
    ./persist-network.nix
    ./pipewire.nix
    ./desktop
    ./linger.nix
    ./opencode
    ./ssh-agent.nix
    ./vm-guest.nix
    ./vfio.nix
    ./btrfs.nix
    ./zfs.nix
    ./zrepl.nix
    ./usb-awake.nix
    ./fonts
    ./nix-builder.nix
    ./users.nix
    ./networking
  ];
  config = mkMerge [
    (mkIf config.system.autoUpgrade.enable {
      programs.git.enable = true;
      programs.git.config = {
        safe.directory = "/etc/nixos";
      };
    })
    {
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
          enableSSHSupport = false;
        };
      };
      programs.nix-ld = mkIf config.personalConfig.system.remoteDevSupport {
        enable = true;
        libraries = with pkgs; [
          stdenv.cc.cc
          gcc-unwrapped.lib
          zlib
          fuse3
          icu
          nss
          openssl
          curl
          expat
          libgcc
          libllvm
          glib
          gtk3
          libGL
          xorg.libX11
          xorg.libXext
          xorg.libXrender
          xorg.libXtst
          xorg.libXi
          fontconfig
          freetype
        ];
      };
    }
  ];
}

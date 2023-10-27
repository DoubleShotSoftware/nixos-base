{ config, lib, options, pkgs, ... }:
with lib;
with builtins;
let
  cfg = config.personalConfig.linux.immersedvr;
  immersedUrl = "https://static.immersed.com/dl/Immersed-x86_64.AppImage";
  immersed = pkgs.appimageTools.wrapType2
    {
      # or wrapType1
      name = "immersed";
      src = pkgs.fetchurl {
        url = immersedUrl;
        hash = "sha512-SHrxURrVkYO9FpZd21sZVE8GXRuSCg+XhQrCWAOQTbXbQV5PvdGTcvG2aHQA6KJ+fLwckdWIKPT40Vw4KFYQVg==";
      };
      extraPkgs = pkgs: with pkgs; [
        avahi
        libdatrie
        cups
        dbus
        enchant
        libepoxy
        libffi
        flac
        libgcrypt
        gst_all_1.gstreamer
        gst_all_1.gstreamermm
        gst_all_1.gst-vaapi
        gst_all_1.gst-libav
        gst_all_1.gst-plugins-rs
        gst_all_1.gst-plugins-ugly
        gst_all_1.gst-plugins-good
        gst_all_1.gst-plugins-base
        pango
        pcre
        pixman
        libpulseaudio
        librsvg
        cairo
        libseccomp
        libsoup
        libtasn1
        libtiff
        libvorbis
        libwebp
        vaapiVdpau
        vaapiIntel
        libvdpau-va-gl
        libva
        libva-utils
        libva-minimal
        libva1-minimal
        libva1
        libdrm
        nss
        linuxPackages.v4l2loopback
        v4l-utils
        libv4l
        brotli
        android-tools
        wayland
        adb-sync
        libthai
        ibus
        ibus-engines.libthai
        gdk-pixbuf
        gdk-pixbuf-xlib
        glib
        glib-networking
        dconf
        at-spi2-atk
        gtk3
        libcanberra-gtk3
        libcanberra
      ];
    };
  bootModules = [
    "v4l2loopback"
  ];
in
{
  options.personalConfig.linux.immersedvr.enable = mkOption {
    type = types.bool;
    default = false;
    description = "Enable the immersedvr desktop app image package.";
  };
  config = mkIf cfg.enable {
    boot = {
      extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
      initrd = {
        availableKernelModules = bootModules;
        kernelModules = bootModules;
      };
    };
    environment.systemPackages = with pkgs;
      [
        immersed
      ];
  };
}

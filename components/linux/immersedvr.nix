{ config, lib, options, pkgs, ... }:
with lib;
with builtins;
let
  cfg = config.personalConfig.linux.immersedvr;
  immersedUrl = "https://static.immersed.com/dl/Immersed-x86_64.AppImage";
  immersed = pkgs.appimageTools.wrapType2 {
    # or wrapType1
    name = "immersed";
    src = pkgs.fetchurl {
      url = immersedUrl;
      hash = "sha256-baor2NPCxHnBuPCaXy8eLQDXawEz480Z4LzjGflsCq0=";
    };
    extraPkgs = pkgs:
      with pkgs; [
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
        pipewire
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
        amdvlk
        libvdpau-va-gl
        libva-utils
        libva
        mesa
        libva-minimal
        libva1-minimal
        libva1
        intel-media-driver # LIBVA_DRIVER_NAME=iHD
        vaapiIntel # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
        vaapiVdpau
        libvdpau-va-gl
        libdrm
        nss
        linuxPackages.v4l2loopback
        v4l-utils
        libv4l
        brotli
        android-tools
        wayland
        wayland-utils
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
  bootModules = [ "v4l2loopback" "uinput" ];
in {
  options.personalConfig.linux.immersedvr.enable = mkOption {
    type = types.bool;
    default = false;
    description = "Enable the immersedvr desktop app image package.";
  };
  config = mkIf cfg.enable {
    hardware.uinput.enable = true;
    boot = {
      extraModulePackages = with config.boot.kernelPackages; [
        v4l2loopback
      ];
      initrd = {
        availableKernelModules = bootModules;
        kernelModules = bootModules;
      };
    };
    environment.systemPackages = with pkgs; [ immersed ];
  };
}

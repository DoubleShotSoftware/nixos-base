{ config, lib, options, pkgs, ... }:
with lib;
with builtins;
let
  users = config.personalConfig.users;
  personalPackages = if (config.personalConfig.machineType == "personal") then
    with pkgs; [ mpvScripts.mpris playerctl vlc moonlight-qt calibre ]
  else
    [ ];
  desktopPackages = (with pkgs; [
    cpupower-gui
    wg-netmanager
    xorg.xhost
    networkmanagerapplet
    remmina
    blueman
    xdg-dbus-proxy
    virt-manager
  ]) ++ personalPackages;
  desktopEnabled = any (userConfig: userConfig.desktop != "disabled")
    (mapAttrsToList (user: userConfig: userConfig) users);
  desktopUsers = mapAttrs (user: config:
    trace "Enabling Wall directory and desktop packages for user: ${user}" {
      home = {
        packages = desktopPackages;
        sessionVariables = {
          MOZ_ENABLE_WAYLAND = 1;
          MOZ_USE_XINPUT2 = "1";
        };
        file = {
          "Wall" = {
            source = ./Wall;
            recursive = true;
          };
        };
      };
    }) (filterAttrs (user: userConfig: userConfig.desktop != "disabled") users);
  mpvConfig = mapAttrs (user: config:
    trace "Enabling MPV Config for user: ${user}" {
      programs.mpv = {
        enable = true;
        config = {
          profile = "gpu-hq";
          force-window = true;
          ytdl-format = "bestvideo+bestaudio";
          cache-default = 4000000;
          gpu-context = "wayland";
        };
      };
    }) (filterAttrs (user: userConfig: userConfig.desktop != "disabled") users);
in {
  imports = [ ./gtk.nix ./gnome ];
  config = lib.mkMerge ([
    (lib.mkIf desktopEnabled (trace "Adding Udev Rules for desktop devices" {
      services.udev.extraRules = ''
        ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="3297", ATTR{idProduct}=="1969",  ATTR{power/autosuspend}="500", ATTR{power/autosuspend}="500000"
        ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="05ac", ATTR{idProduct}=="0265",  ATTR{power/autosuspend}="500", ATTR{power/autosuspend}="500000"
      '';
    }))
    (lib.mkIf desktopEnabled (trace "Enabling Display Manager" {
      environment.systemPackages = with pkgs; [
        xorg.xorgserver
        xorg.xf86inputevdev
        xorg.xf86inputlibinput
        xorg.xinit
      ];
      #          xdg.portal = {
      #            enable = true;
      #            xdgOpenUsePortal = true;
      #          };
      services = {
        flatpak.enable = true;
        xserver = {
          enable = true;
          layout = "us";
          displayManager = {
            session = [{
              manage = "desktop";
              name = "xsession";
              start = "exec $HOME/.xsession";
            }];
          };
        };
      };
      programs.xwayland.enable = true;
    }))
    (lib.mkIf desktopEnabled ({ home-manager.users = desktopUsers; }))
    (lib.mkIf (config.personalConfig.machineType == "personal") ({
      home-manager.users = mpvConfig;
    }))
  ]);
}

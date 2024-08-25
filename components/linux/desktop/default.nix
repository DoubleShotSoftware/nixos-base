{ config, lib, options, pkgs, ... }:
with lib;
with builtins;
let
  users = config.personalConfig.users;
  personalPackages = if (config.personalConfig.machineType == "personal") then
    with pkgs; [ mpvScripts.mpris playerctl vlc moonlight-qt  ]
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
          MOZ_ENABLE_WAYLAND = if config.desktop == "gnome" then 1 else 0;
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
  imports = [ ./gnome ./i3 ];
  config = lib.mkMerge ([
    (lib.mkIf desktopEnabled (trace "Adding Udev Rules for desktop devices" {
      services.udev.extraRules = ''
        ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="3297", ATTR{idProduct}=="1969",  ATTR{power/autosuspend}="500", ATTR{power/autosuspend}="500000"
        ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="05ac", ATTR{idProduct}=="0265",  ATTR{power/autosuspend}="500", ATTR{power/autosuspend}="500000"
      '';
    }))
    (lib.mkIf desktopEnabled (trace "Enabling Desktop Support" {
      hardware = {
        bluetooth = {
          enable = true;
          powerOnBoot = true;
          settings = {
            General = {
              Experimental = true;
              Enable = "Source,Sink,Media,Socket";
            };
          };
        };
      };
      programs = {
        dconf = { enable = true; };
        seahorse.enable = true;
      };
      environment = {
        systemPackages = with pkgs; [
          gcr
          libsecret
          xorg.xorgserver
          xorg.xf86inputevdev
          xorg.xf86inputlibinput
          xorg.xinit
        ];
      };
      security.rtkit.enable = true;
      services = {
        gvfs.enable = true;
        packagekit.enable = true;
        blueman.enable = true;
        gnome.gnome-keyring.enable = true;
        pipewire = {
          enable = true;
          systemWide = false;
          pulse.enable = true;
          wireplumber = {
            enable = true;
            extraConfig = {
              "monitor.bluez.properties" = {
                "bluez5.enable-sbc-xq" = true;
                "bluez5.enable-msbc" = true;
                "bluez5.enable-hw-volume" = true;
                "bluez5.roles" = [ "hsp_hs" "hsp_ag" "hfp_hf" "hfp_ag" ];
              };
            };
          };
        };
        xserver = {
          enable = true;
          layout = "us";
          libinput = {
            enable = true;
            touchpad = { naturalScrolling = true; };
          };
          desktopManager = { xterm.enable = false; };
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

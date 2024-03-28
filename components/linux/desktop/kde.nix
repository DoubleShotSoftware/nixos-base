{ config, lib, options, pkgs, ... }:
with lib;
with builtins;
let
  kdeActive = any (desktop: desktop == "kde")
    (mapAttrsToList (user: userConfig: userConfig.desktop)
      (filterAttrs (user: userConfig: userConfig.desktop == "kde")
        config.personalConfig.users));
in {
  config = lib.mkIf kdeActive {
    services = {
      touchegg.enable = true;
      xserver = {
        enable = true;
        libinput = {
          enable = true;
          touchpad = {
            naturalScrolling = true;
            middleEmulation = true;
          };
        };
        displayManager = {
          sddm = {
            enable = true;
            enableHidpi = true;
          };
        };
        desktopManager = {
          plasma5 = {
            enable = true;
            useQtScaling = true;
          };
        };
      };
    };
    qt = {
      enable = true;
      platformTheme = "gnome";
      style = "adwaita-dark";
    };
    environment.systemPackages = with pkgs; [ libsForQt5.bismuth ];
    environment.plasma5.excludePackages = with pkgs.libsForQt5; [
      konsole
      oxygen
    ];
  };
}

{ config, lib, pkgs, inputs, desktop, ... }:
with lib;
with builtins;
let
  gnomeEnabled = any (userConfig: userConfig.desktop == "gnome")
    (mapAttrsToList (user: userConfig: userConfig) config.personalConfig.users);
  gnomeConfigs = mapAttrs (user: config:
    (trace "Enabling Gnome for user: ${user}" {
      imports = [  ];
      home.packages = with pkgs; [
        polkit_gnome
        libqalculate
        qalculate-gtk
        dconf2nix
        pop-launcher
        gnome.nautilus
        gnome.gvfs
        gtk_engines
        arc-theme
        materia-theme
        material-icons
        lxappearance
        gnome.dconf-editor
        gnome.gnome-tweaks
        gnomeExtensions.settingscenter
        gnomeExtensions.appindicator
        gnomeExtensions.pop-shell
        gnomeExtensions.battery-time
        gnomeExtensions.caffeine
        gnomeExtensions.freon
        gnomeExtensions.vitals
        catppuccin-gtk
        catppuccin
        catppuccin-cursors
      ];
    })) (filterAttrs (user: userConfig: userConfig.desktop == "gnome")
      config.personalConfig.users);
in {
  config = lib.mkMerge ([
    (lib.mkIf (gnomeEnabled) (trace "Enabling Gnome & GDM" {
      services = {
        dbus.packages = with pkgs; [ gnome2.GConf ];
        xserver = {
          displayManager.gdm.enable = true;
          desktopManager.gnome.enable = true;
        };
        udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];
      };
      environment.gnome.excludePackages =
        (with pkgs; [ gnome-photos gnome-tour ]) ++ (with pkgs.gnome; [
          cheese # webcam tool
          gnome-music
          gnome-terminal
          epiphany # web browser
          geary # email reader
          evince # document viewer
          gnome-characters
          totem # video player
          tali # poker game
          iagno # go game
          hitori # sudoku game
          atomix # puzzle game
        ]);
    }))
    (lib.mkIf gnomeEnabled { home-manager.users = gnomeConfigs; })
  ]);
}

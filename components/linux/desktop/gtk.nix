{ config, lib, pkgs, inputs, desktop, ... }:
with lib;
with builtins;
let
  users = config.personalConfig.users;
  gtkUsers = (lib.attrsets.mapAttrs' (user: userConfig:
    (trace "Enabling gtk config for user: ${user}"
      (lib.attrsets.nameValuePair (user) ({
        gtk = {
          # Enable GTK configuration with Tokyo Night theme
          enable = true;
          cursorTheme = {
            package = pkgs.nordic;
            name = "Nordic-cursors";
            size = 24;
          };
          gtk2.extraConfig = ''
            gtk-theme-name = "Tokyonight-Dark"
            gtk-icon-theme-name="Nordic-darker"
            gtk-font-name="Fira Sans Regular"
            gtk-toolbar-style=GTK_TOOLBAR_BOTH_HORIZ
            gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
            gtk-button-images=0
            gtk-menu-images=0
            gtk-enable-event-sounds=1
            gtk-enable-input-feedback-sounds=1
            gtk-xft-antialias=1
            gtk-xft-hinting=1
            gtk-xft-hintstyle="hintslight"
            gtk-xft-rgba="rgb"
          '';
          gtk3.extraConfig = {
            gtk-theme-name = "Tokyonight-Dark";
            gtk-font-name = "Fira Sans Regular";
            gtk-icon-theme-name = "Nordic-darker";
          };
          gtk4.extraConfig = {
            gtk-theme-name = "Tokyonight-Dark";
            gtk-icon-theme-name = "Nordic-darker";
          };
          theme = {
            package = pkgs.tokyonight-gtk-theme;
            name = "Tokyonight-Dark";
          };
          font = {
            name = "Fira Sans Regular";
            package = pkgs.fira;
          };
          iconTheme = {
            name = "Nordic-darker";
            package = pkgs.nordic;
          };
        };
      }))))
    (filterAttrs (user: userConfig: userConfig.desktop != "disabled") users));
in { config = mkMerge ([{ home-manager.users = gtkUsers; }]); }

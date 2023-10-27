{ config, lib, pkgs, inputs, desktop, ... }:
with lib;
with builtins;
let
  users = config.personalConfig.users;
  gtkUsers = (lib.attrsets.mapAttrs'
    (user: userConfig: (
      trace ''Enabling gtk config for user: ${user}''
        (lib.attrsets.nameValuePair
          (user)
          ({
            gtk = {

              enable = true;
              cursorTheme = {
                package = pkgs.nordzy-cursor-theme;
                size = 14;
                name = "Nordzy-cursors";
              };
              gtk2.extraConfig = ''
                gtk-theme-name = "Materia-dark"
                gtk-icon-theme-name="Arc"
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
                gtk-theme-name = "Materia-dark";
                gtk-font-name = "Fira Sans Regular";
                gtk-icon-theme-name = "Arc";
              };
              theme = {
                package = pkgs.materia-theme;
                name = "Materia-dark";
              };
              font = {
                name = "Fira Sans Regular";
                package = pkgs.fira;
              };
              iconTheme = {
                name = "Arc";
                package = pkgs.arc-icon-theme;
              };
            };
          }))
    ))
    (filterAttrs (user: userConfig: userConfig.desktop != "disabled") users)
  );
in
{
  config = mkMerge ([
    {
      home-manager.users = gtkUsers;
    }
  ]);
}

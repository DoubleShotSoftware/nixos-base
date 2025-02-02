{ config, lib, pkgs, inputs, desktop, ... }:
with lib;
with builtins;
let
  portals = with pkgs; [ xdg-desktop-portal-gnome xdg-desktop-portal ];
  gnomeEnabled = any (userConfig: userConfig.desktop == "gnome")
    (mapAttrsToList (user: userConfig: userConfig) config.personalConfig.users);
  gnomeConfigs = mapAttrs (user: config:
    (trace "Enabling Gnome for user: ${user}" {
      imports = [ ];
      home.packages = with pkgs; [
        polkit_gnome
        libqalculate
        qalculate-gtk
        dconf2nix
        pop-launcher
        gnome.nautilus
        gnome.gvfs
        gtk_engines
        gnome.dconf-editor
        gnome.gnome-tweaks
        gnomeExtensions.settingscenter
        gnomeExtensions.appindicator
        gnomeExtensions.pop-shell
        gnomeExtensions.caffeine
        gnomeExtensions.freon
        gnomeExtensions.vitals
        gnomeExtensions.wallpaper-slideshow
        gnomeExtensions.open-bar
        gnomeExtensions.tiling-shell
        catppuccin-cursors
        nordic
      ];
      ## Dark mode breaks by default with xdg-desktop-portal-gtk
      ## https://github.com/NixOS/nixpkgs/issues/274554#issuecomment-2211307799
      dconf = {
        settings = {
          "org/gnome/desktop/interface" = { color-scheme = "prefer-dark"; };
          "org/gnome/shell/keybindings" = {
            "switch-to-application-1" = [ ];
            "switch-to-application-2" = [ ];
            "switch-to-application-3" = [ ];
            "switch-to-application-4" = [ ];
            "switch-to-application-5" = [ ];
            "switch-to-application-6" = [ ];
            "switch-to-application-7" = [ ];
            "switch-to-application-8" = [ ];
            "switch-to-application-9" = [ ];
            "switch-to-application-0" = [ ];
            "toggle-overview" = [ "" ];
          };
          "org/gnome/desktop/interface" = { enable-hot-corners = false; };
          "org/gnome/shell/extensions/pop-shell" = {
            active-hint = true;
            active-hint-color = "rgba(122,162,247, 0.8)";
            gap-inner = 10;
            gap-outer = 10;
            hint-color-rgba = "rgba(122,162,247, 0.8)";
            smart-gaps = true;
            snap-to-grid = false;
            tile-by-default = true;
          };
          "org/desktop/wm/preferences" = {
            "focus-mode" = "mouse";
            num-workspaces = 10;

          };
          "org/gnome/mutter" = {
            attach-modal-dialogs = true;
            dynamic-workspaces = false;
            edge-tiling = false;
            experimental-features =
              [ "scale-monitor-framebuffer" "variable-refresh-rate" ];
            focus-change-on-pointer-rest = true;
            overlay-key = "";
            workspaces-only-on-primary = true;
          };
          "org/gnome/mutter/keybindings" = {
            toggle-tiled-left = [ ];
            toggle-tiled-right = [ ];
          };
          "org/gnome/mutter/wayland/keybindings" = { restore-shortcuts = [ ]; };
          "org/gnome/desktop/wm/keybindings" = {
            close = [ "<Super>q" "<Alt>F4" ];
            toggle-fullscreen = [ "<Super>f" ];
            toggle-maximized = [ "<Super>m" ];
            minimize = [ "" ];
            "move-to-workspace-1" = [ "<Shift><Super>1" ];
            "move-to-workspace-2" = [ "<Shift><Super>2" ];
            "move-to-workspace-3" = [ "<Shift><Super>3" ];
            "move-to-workspace-4" = [ "<Shift><Super>4" ];
            "move-to-workspace-5" = [ "<Shift><Super>5" ];
            "move-to-workspace-6" = [ "<Shift><Super>6" ];
            "move-to-workspace-7" = [ "<Shift><Super>7" ];
            "move-to-workspace-8" = [ "<Shift><Super>8" ];
            "move-to-workspace-9" = [ "<Shift><Super>9" ];
            "move-to-workspace-0" = [ "<Shift><Super>0" ];

            "switch-to-workspace-1" = [ "<Super>1" ];
            "switch-to-workspace-2" = [ "<Super>2" ];
            "switch-to-workspace-3" = [ "<Super>3" ];
            "switch-to-workspace-4" = [ "<Super>4" ];
            "switch-to-workspace-5" = [ "<Super>5" ];
            "switch-to-workspace-6" = [ "<Super>6" ];
            "switch-to-workspace-7" = [ "<Super>7" ];
            "switch-to-workspace-8" = [ "<Super>8" ];
            "switch-to-workspace-9" = [ "<Super>9" ];
            "switch-to-workspace-0" = [ "<Super>0" ];
          };
          "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" =
            {
              binding = "<Control><Super>Return";
              command = "${pkgs.wezterm}/bin/wezterm";
              name = "Terminal";
            };
        };
      };
      qt = {
        enable = true;
        platformTheme.name = "Adwaita-dark";
        style = {
          name = "Adwaita-dark";
          package = pkgs.adwaita-qt;
        };
      };
    })) (filterAttrs (user: userConfig: userConfig.desktop == "gnome")
      config.personalConfig.users);
in {
  config = lib.mkMerge ([
    (lib.mkIf (gnomeEnabled) (trace "Enabling Gnome & GDM" {
      xdg.portal = {
        enable = true;
        config = { common = { default = [ "gnome" ]; }; };
        extraPortals = portals;
      };
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

{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  config = config.homeConfig;
in {
  options.homeConfig.gnome = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to configure gnome in home manager";
    };
  };
  config = {
    home.packages = with pkgs; [
      # flatpak
      # gnome.dconf-editor
      # gnome.gnome-tweaks
      # gnome.gnome-software
      # polkit_gnome
      # qalculate-gtk
      # gnome.nautilus
      # gnome.gvfs

      libqalculate
      dconf2nix
      pop-launcher
      gtk_engines
      arc-theme
      materia-theme
      material-icons
      gnomeExtensions.settingscenter
      gnomeExtensions.appindicator
      gnomeExtensions.pop-shell
      gnomeExtensions.caffeine
      gnomeExtensions.freon
      gnomeExtensions.vitals
      gnomeExtensions.wallpaper-slideshow
      gnomeExtensions.open-bar
      catppuccin-cursors
      nordic
      material-cursors
    ];
    dconf = {
      settings = {
        "org/gnome/desktop/interface" = {color-scheme = "prefer-dark";};
        "org/gnome/shell/keybindings" = {
          "switch-to-application-1" = [];
          "switch-to-application-2" = [];
          "switch-to-application-3" = [];
          "switch-to-application-4" = [];
          "switch-to-application-5" = [];
          "switch-to-application-6" = [];
          "switch-to-application-7" = [];
          "switch-to-application-8" = [];
          "switch-to-application-9" = [];
          "switch-to-application-0" = [];
          "toggle-overview" = [""];
        };
        "org/gnome/desktop/interface" = {enable-hot-corners = false;};
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
          experimental-features = ["scale-monitor-framebuffer" "variable-refresh-rate"];
          focus-change-on-pointer-rest = true;
          overlay-key = "";
          workspaces-only-on-primary = true;
        };
        "org/gnome/mutter/keybindings" = {
          toggle-tiled-left = [];
          toggle-tiled-right = [];
        };
        "org/gnome/mutter/wayland/keybindings" = {restore-shortcuts = [];};
        "org/gnome/desktop/wm/keybindings" = {
          close = ["<Super>q" "<Alt>F4"];
          toggle-fullscreen = ["<Super>f"];
          toggle-maximized = ["<Super>m"];
          minimize = [""];
          "move-to-workspace-1" = ["<Shift><Super>1"];
          "move-to-workspace-2" = ["<Shift><Super>2"];
          "move-to-workspace-3" = ["<Shift><Super>3"];
          "move-to-workspace-4" = ["<Shift><Super>4"];
          "move-to-workspace-5" = ["<Shift><Super>5"];
          "move-to-workspace-6" = ["<Shift><Super>6"];
          "move-to-workspace-7" = ["<Shift><Super>7"];
          "move-to-workspace-8" = ["<Shift><Super>8"];
          "move-to-workspace-9" = ["<Shift><Super>9"];
          "move-to-workspace-0" = ["<Shift><Super>0"];

          "switch-to-workspace-1" = ["<Super>1"];
          "switch-to-workspace-2" = ["<Super>2"];
          "switch-to-workspace-3" = ["<Super>3"];
          "switch-to-workspace-4" = ["<Super>4"];
          "switch-to-workspace-5" = ["<Super>5"];
          "switch-to-workspace-6" = ["<Super>6"];
          "switch-to-workspace-7" = ["<Super>7"];
          "switch-to-workspace-8" = ["<Super>8"];
          "switch-to-workspace-9" = ["<Super>9"];
          "switch-to-workspace-0" = ["<Super>0"];
        };
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
          binding = "<Control><Super>Return";
          command = "${pkgs.kitty}/bin/kitty";
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
  };
}

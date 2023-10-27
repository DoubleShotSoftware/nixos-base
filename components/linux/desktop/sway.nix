{ config, lib, pkgs, inputs, desktop, ... }:
with lib;
with builtins;
let
  users = config.personalConfig.users;
  gapSize = 10;
  idleCmd = ''
    swayidle -w \
        timeout 300 'swaylock --daemonize --ignore-empty-password --color 3c3836' \
        timeout 600 'swaymsg "output * dpms off"' \
             resume 'swaymsg "output * dpms on"' \
        before-sleep 'swaylock --daemonize --ignore-empty-password --color 3c3836'
  '';
  mod = "Mod4";

  swayEnabled = any
    (userConfig: userConfig.desktop == "sway")
    (
      mapAttrsToList (user: userConfig: userConfig) users
    );
  dbus-sway-environment = pkgs.writeTextFile {
    name = "dbus-sway-environment";
    destination = "/bin/dbus-sway-environment";
    executable = true;
    text = ''
      dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway
      systemctl --user stop pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
      systemctl --user start pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
    '';
  };
  enableSwayForUser = user: userConfig: {
    home.packages = with pkgs; [
      wdisplays
      wf-recorder
      slurp
      wl-clipboard
      grim
      brightnessctl
      pamixer
    ];
    wayland.windowManager.sway = {
      enable = true;
      package = pkgs.swayfx;
      wrapperFeatures.gtk = true;
      extraConfig = ''
        seat seat0 xcursor_theme Nordzy-cursors 14
      '';

      config = rec {
        keybindings =
          lib.mkOptionDefault
            {
              "${mod}+Shift+e" = "exit";
              "XF86AudioPlay" = "exec playerctl play-pause";
              "XF86AudioNext" = "exec playerctl next";
              "XF86AudioPrev" = "exec playerctl previous";
              "XF86AudioMute" = "exec pamixer -t";
              "XF86AudioRaiseVolume" = "exec pamixer -i 5";
              "XF86AudioLowerVolume" = "exec pamixer -d 5";
              "XF86MonBrightnessDown" = "exec brightnessctl s 5%-";
              "XF86MonBrightnessUp" = "exec brightnessctl s +5%";
              "--release Print" =
                "exec grimshot --notify save area ~/scr/scr_`date +%Y%m%d.%H.%M.%S`.png";
              "--release ${mod}+Print" =
                "exec grimshot --notify save output ~/scr/scr_`date +%Y%m%d.%H.%M.%S`.png";
            };
        bars = [{
          position = "bottom";
          statusCommand =
            "${pkgs.i3status-rust}/bin/i3status-rs ${./i3status-rust.toml}";
          trayOutput = "primary";
          fonts = {
            names = [ "Fira Code" ];
            size = 12.0;
          };
        }];
        modifier = mod;
        # Use kitty as default terminal
        terminal = "${pkgs.kitty}/bin/kitty";
        startup = [ ];
        fonts = {
          names = [ "Fira Code" "FontAwesome5Free" ];
          style = "Bold Semi-Condensed";
          size = 11.0;
        };
        gaps = {
          bottom = gapSize;
          horizontal = gapSize;
          inner = gapSize;
          left = gapSize;
          outer = gapSize;
          right = gapSize;
          smartBorders = "on";
          smartGaps = true;
          top = gapSize;
          vertical = gapSize;
        };
        colors = {
          focused = {
            border = "#9aa5ce";
            background = "#16161d";
            text = "#c0caf5";
            indicator = "#9aa5ce";
            childBorder = "#9aa5ce";
          };
          focusedInactive = {
            border = "#16161d";
            background = "#16161d";
            text = "#c0caf5";
            indicator = "#16161d";
            childBorder = "#16161d";
          };
          unfocused = {
            border = "#16161d";
            background = "#16161d";
            text = "#c0caf5";
            indicator = "#16161d";
            childBorder = "#16161d";
          };
        };
        floating = {
          criteria =
            [{ title = "Steam - Update News"; } { class = "Pavucontrol"; }];
        };
        output = {
          "*" = {
            bg = "~/Wall/alex-knight-5-GNa303REg-unsplash.jpg fill";
            scale = "1";
          };
        };
      };
    };
    services = {
      swayidle = {
        enable = true;
        events = [
          {
            event = "before-sleep";
            command = "${pkgs.swaylock}/bin/swaylock";
          }
          {
            event = "lock";
            command = "lock";
          }
        ];
      };
    };
    services = {
      mako = {
        enable = true;
        icons = true;
        iconPath = "${pkgs.arc-icon-theme}";
      };
    };
    programs = {

      rofi = {
        enable = true;
        package = pkgs.rofi-wayland;
        plugins = [
          pkgs.rofi-emoji
          pkgs.rofi-systemd
          pkgs.rofi-power-menu
          pkgs.rofi-file-browser
          pkgs.rofi-pulse-select
        ];
        extraConfig = {
          modi = "window,drun,ssh,combi";
          combi-modi = "window,drun,ssh,run";
        };
        font = "Fira Code 12";
      };
    };
  };
  videoUsers = mapAttrsToList
    (user: userConfig:
      if (config.nvim) then
        (
          trace ''Adding user: ${user} to group video''
            {
              users.users.${user}.extraGroups = [ "video" ];
            }
        ) else { })
    (filterAttrs (user: userConfig: userConfig.desktop == "sway") users);
  swayConfigs = mapAttrs
    (user: config:
      if (config.nvim) then
        (
          trace ''Enabling sway for user: ${user}''
            enableSwayForUser
            user
        ) else { })
    (filterAttrs (user: userConfig: userConfig.userType != "system") config.personalConfig.users);

in
{
  config = lib.mkMerge ([
    (lib.mkIf swayEnabled (
      {
        security.polkit.enable = true;
        xdg.portal = {
          enable = true;
          wlr.enable = true;
          # gtk portal needed to make gtk apps happy
          extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
        };
      }))
    (lib.mkIf swayEnabled (
      trace ''Enablind Sway Home Manager for users''
        { home-manager.users = swayConfigs; }
    ))
  ]);

}

{ config, lib, pkgs, inputs, desktop, ... }:
with lib;
with builtins;
let
  mod = "Mod4";
  i3Enabled = any (userConfig: userConfig.desktop == "i3")
    (mapAttrsToList (user: userConfig: userConfig) config.personalConfig.users);
  i3Configs = mapAttrs (user: config:
    (trace "Enabling i3 for user: ${user}" {
      xdg.configFile."i3status-rust/config.toml".source = ../i3status-rust.toml;
      home.packages = with pkgs; [
        gnome.gnome-software
        arandr
        nitrogen
        i3status-rust
        blueman
      ];
      programs.rofi = {
        enable = true;
        plugins = with pkgs; [
          rofi-emoji
          rofi-systemd
          rofi-power-menu
          rofi-file-browser
          rofi-top
          rofi-rbw
          rofi-calc
          rofi-systemd
          rofi-bluetooth
        ];
        extraConfig = {
          modi = "window,drun,ssh,combi";
          combi-modi = "window,drun,ssh,run";
        };
        font = "Fira Code 12";
      };
      xsession = {
        enable = true;
        profileExtra = ''
          eval $(${pkgs.gnome3.gnome-keyring}/bin/gnome-keyring-daemon --daemonize --components=ssh,secrets)
          export SSH_AUTH_SOCK
          export DESKTOP_SESSION=gnome
        '';
        windowManager.i3 = {
          enable = true;
          package = pkgs.i3;
          extraConfig = ''
            smart_gaps on
            smart_borders on
            gaps inner 10
            gaps outer 10
            font pango:Fira Code 12
            exec blueman-applet
            exec nitrogen --restore
          '';
          config = {
            modifier = mod;
            fonts = [ "DejaVu Sans Mono, FontAwesome 6" ];
            keybindings = lib.mkOptionDefault {
              "${mod}+d" = ''
                exec ${pkgs.rofi}/bin/rofi -show combi -show-icons -icon-theme "bloom-dark" 
              '';
              "${mod}+x" =
                "exec sh -c '${pkgs.maim}/bin/maim -s | xclip -selection clipboard -t image/png'";
              "${mod}+Shift+x" =
                "exec sh -c '${pkgs.i3lock}/bin/i3lock -c 222222 & sleep 5 && xset dpms force of'";
              "${mod}+Return" = "exec ${pkgs.kitty}/bin/kitty";
              "${mod}+Shift+f" = "exec ${pkgs.firefox}/bin/firefox -p";
              "${mod}+Shift+q" = "kill";
              "XF86MonBrightnessUp" = "exec brightnessctl s +10%";
              "XF86MonBrightnessDown" = "exec brightnessctl s 10%-";

              # Focus
              "${mod}+h" = "focus left";
              "${mod}+j" = "focus down";
              "${mod}+k" = "focus up";
              "${mod}+l" = "focus right";

              # Move
              "${mod}+Shift+h" = "move left";
              "${mod}+Shift+j" = "move down";
              "${mod}+Shift+k" = "move up";
              "${mod}+Shift+l" = "move right";

              # Workspaces
              "${mod}+1" = "workspace number 1";
              "${mod}+2" = "workspace number 2";
              "${mod}+3" = "workspace number 3";
              "${mod}+4" = "workspace number 4";
              "${mod}+5" = "workspace number 5";
              "${mod}+6" = "workspace number 6";
              "${mod}+7" = "workspace number 7";
              "${mod}+8" = "workspace number 8";
              "${mod}+9" = "workspace number 9";
              "${mod}+0" = "workspace number 10";
              "${mod}+Shift+1" = "move container to workspace number 1";
              "${mod}+Shift+2" = "move container to workspace number 2";
              "${mod}+Shift+3" = "move container to workspace number 3";
              "${mod}+Shift+4" = "move container to workspace number 4";
              "${mod}+Shift+5" = "move container to workspace number 5";
              "${mod}+Shift+6" = "move container to workspace number 6";
              "${mod}+Shift+7" = "move container to workspace number 7";
              "${mod}+Shift+8" = "move container to workspace number 8";
              "${mod}+Shift+9" = "move container to workspace number 9";
              "${mod}+Shift+0" = "move container to workspace number 10";

              "${mod}+b" = "splith";
              "${mod}+v" = "splitv";
              "${mod}+s" = "layout stacking";
              "${mod}+w" = "layout tabbed";
              "${mod}+e" = "layout toggle split";
              "${mod}+f" = "fullscreen";
              "${mod}+Shift+space" = "floating toggle";
              "${mod}+space" = "focus mode_toggle";
              "${mod}+a" = "focus parent";
              "${mod}+r" = ''mode "resize"'';
            };
            bars = [{
              position = "bottom";
              statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs";
              trayOutput = "primary";
              fonts = {
                names = [ "Fira Code" ];
                size = 14.0;
              };
            }];
          };
        };
      };
      services.dunst = {
        enable = true;
        iconTheme = {
          name = "Arc";
          package = pkgs.arc-icon-theme;
        };
      };
      services.picom = {
        enable = true;
        package = pkgs.picom-next;
        fade = true;
        fadeDelta = 5;
        shadow = true;
        shadowOffsets = [ (-7) (-7) ];
        shadowOpacity = 0.7;
        shadowExclude = [ "window_type *= 'normal' && ! name ~= ''" ];
        activeOpacity = 1.0;
        inactiveOpacity = 0.8;
        menuOpacity = 0.75;
        backend = "glx";
        vSync = true;
      };
    })) (filterAttrs (user: userConfig: userConfig.desktop == "i3")
      config.personalConfig.users);
in {
  config = lib.mkMerge ([
    (lib.mkIf (i3Enabled) (trace "Enabling i3 & LightDM" {
      imports = [ ../gtk.nix ];
      services = {
        xserver = {
          layout = "us";
          xkbVariant = "";
          enable = true;
          desktopManager = { xterm.enable = false; };
          windowManager.i3.enable = true;
        };
      };
      systemd = {
        user.services.polkit-gnome-authentication-agent-1 = {
          description = "polkit-gnome-authentication-agent-1";
          wantedBy = [ "graphical-session.target" ];
          wants = [ "graphical-session.target" ];
          after = [ "graphical-session.target" ];
          serviceConfig = {
            Type = "simple";
            ExecStart =
              "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
            Restart = "on-failure";
            RestartSec = 1;
            TimeoutStopSec = 10;
          };
        };
      };
    }))
    (lib.mkIf i3Enabled { home-manager.users = i3Configs; })
  ]);
}

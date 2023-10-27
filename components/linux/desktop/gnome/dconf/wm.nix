# Generated via dconf2nix: https://github.com/gvolpe/dconf2nix
{ lib, ... }:

with lib.hm.gvariant;

{
  dconf.settings = {
    "org/gnome/desktop/wm/keybindings" = {
      close = [ "<Super>q" "<Alt>F4" ];
      maximize = [ ];
      minimize = [ "<Super>comma" ];
      move-to-monitor-down = [ ];
      move-to-monitor-left = [ ];
      move-to-monitor-right = [ ];
      move-to-monitor-up = [ ];
      move-to-workspace-1 = [ "<Shift><Super>exclam" ];
      move-to-workspace-10 = [ "<Shift><Super>parenright" ];
      move-to-workspace-2 = [ "<Shift><Super>at" ];
      move-to-workspace-3 = [ "<Shift><Super>numbersign" ];
      move-to-workspace-4 = [ "<Shift><Super>dollar" ];
      move-to-workspace-5 = [ "<Shift><Super>percent" ];
      move-to-workspace-6 = [ "<Shift><Super>asciicircum" ];
      move-to-workspace-7 = [ "<Shift><Super>ampersand" ];
      move-to-workspace-8 = [ "<Shift><Super>asterisk" ];
      move-to-workspace-9 = [ "<Shift><Super>parenleft" ];
      move-to-workspace-down = [ ];
      move-to-workspace-up = [ ];
      switch-input-source = [ ];
      switch-input-source-backward = [ ];
      switch-to-workspace-1 = [ "<Super>1" ];
      switch-to-workspace-10 = [ "<Super>0" ];
      switch-to-workspace-2 = [ "<Super>2" ];
      switch-to-workspace-3 = [ "<Super>3" ];
      switch-to-workspace-4 = [ "<Super>4" ];
      switch-to-workspace-5 = [ "<Super>5" ];
      switch-to-workspace-6 = [ "<Super>6" ];
      switch-to-workspace-7 = [ "<Super>7" ];
      switch-to-workspace-8 = [ "<Super>8" ];
      switch-to-workspace-9 = [ "<Super>9" ];
      switch-to-workspace-down = [ "<Primary><Super>Down" "<Primary><Super>j" ];
      switch-to-workspace-left = [ ];
      switch-to-workspace-right = [ ];
      switch-to-workspace-up = [ "<Primary><Super>Up" "<Primary><Super>k" ];
      toggle-fullscreen = [ "<Super>f" ];
      toggle-maximized = [ "<Super>m" ];
      unmaximize = [ ];
    };

  };
}

{ config, lib, options, pkgs, ... }:

let user = config.personalConfig.macos.yabai.user;
in {
  options.personalConfig.macos.yabai = with lib; {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Install and configure yabai.";
    };
    user = mkOption {
      type = types.str;
      description = "Which user to configure for yabai.";
    };
  };
  config = lib.mkMerge [
    (lib.mkIf (config.personalConfig.macos.yabai.enable && pkgs.system
      == "aarch64-darwin") {
        homebrew = {
          brews = [ "koekeishiya/formulae/yabai" "sketchybar" "skhd" ];
          taps = [ "FelixKratz/formulae" ];
        };
      })
    (lib.mkIf (config.personalConfig.macos.yabai.enable
      && !isNull config.personalConfig.macos.yabai.user && pkgs.system
      == "aarch64-darwin") {
        home-manager.users."${user}" = {
          xdg.configFile."yabai/yabairc" = {
            executable = true;
            source = ../../../configuration/applications/yabairc;
          };
          xdg.configFile."skhd/skhdrc" = {
            executable = true;
            source = ./skhdrc;
          };
          xdg.configFile."sketchybar" = {
            executable = true;
            source = ./sketchybar;
            recursive = true;
          };
          home = {
            file = {
              ".bin/launch-yabai.sh" = {
                executable = true;
                text = ''
                  sudo yabai --load-sa
                  yabai --verbose
                '';
              };
              ".bin/launch-desktop.sh" = {
                executable = true;
                text = ''
                  export PATH="$PATH:/opt/homebrew/bin:$HOME/.bin:$HOME/.local/.bin:$HOME/.cargo/bin"
                  screen -d -m -S yabai -t yabai "$HOME/.bin/launch-yabai.sh"
                  screen -d -m -S skhd -t skhd "skhd -V"
                  screen -d -m -S sketchybar -t sketchybar "cd $HOME/.config/sketchybar && sketchybar"
                '';
              };
              ".bin/sketchybar/update_vdesktop.sh" = {
                executable = true;
                source =
                  ../../../scripts/applications/sketchybar/update_vdir.sh;
              };
            };
          };
        };
      })
  ];
}

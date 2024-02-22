{ config, pkgs, lib, ... }:
with lib;
with builtins;
let
  baseConfig = (builtins.readFile ./kitty.conf);
  users = config.personalConfig.users;
  titleBar = if pkgs.system == "aarch64-darwin" then "macos_titlebar_color #16161e" else "wayland_titlebar_color #16161e";
in
{
  config = mkMerge [
    (lib.mkIf (pkgs.system != "aarch64-darwin")
      {
        home-manager.users = mapAttrs
          (user: userConfig:
            if (userConfig.kitty) then
              trace ''Enabling kitty for ${user}''
                {
                  xdg.configFile = {
                    "kitty/theme.conf" = {
                      source = ./themes/Dark_Pastel.conf;
                    };
                  };
                  programs.kitty = {
                    enable = true;
                    environment = { TERM = "xterm-256color"; };
                    settings = {
                      scrollback_lines = 10000;
                      enable_audio_bell = false;
                      update_check_interval = 0;
                      background_opacity = "0.8";
                      font_size = "12.0";
                      font_family = "FiraCode Nerd Font";
                      bold_font = "auto";
                      italic_font = "auto";
                      bold_italic_font = "auto";
                    };
                    extraConfig = (lib.concatStringsSep "\n" [ baseConfig titleBar ]);
                  };
                } else
              { })
          (filterAttrs (user: userConfig: userConfig.userType != "system") users);
      })
  ];
}

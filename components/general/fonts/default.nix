{ config, lib, options, pkgs, ... }:
with builtins;
with lib;
let
  users = config.personalConfig.users;
in
{
  config = lib.mkMerge [
    (lib.mkIf (pkgs.system != "aarch64-darwin") {
      home-manager.users = mapAttrs
        (user: userConfig:
          trace ''Installing fonts for ${user}''
            {
              home.packages = with pkgs; [
                hack-font
                fira
                fira-code
                fira-mono
                fira-code-symbols
                font-awesome
                nerdfonts
                nerd-font-patcher
                powerline-fonts
                powerline-symbols
                roboto
                jetbrains-mono
                emacs-all-the-icons-fonts
                victor-mono
                iosevka
              ];
            })
        (filterAttrs (user: userConfig: userConfig.desktop != "disabled") users);
    })
  ];
}

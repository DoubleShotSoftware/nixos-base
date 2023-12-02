{ config, lib, options, pkgs, ... }:
with builtins;
with lib;
let
  users = config.personalConfig.users;
  desktopEnabled = any (userConfig: userConfig.desktop != "disabled")
    (mapAttrsToList (user: userConfig: userConfig) users);
  nerdFonts = pkgs.nerdfonts.override {
    fonts = [ "FiraCode" "FiraMono" "VictorMono" "Iosevka" "IosevkaTerm" ];
  };
in {
  config = lib.mkIf desktopEnabled {
    fonts = {
      packages = with pkgs; [
        hack-font
        fira
        fira-code
        fira-mono
        fira-code-symbols
        font-awesome
        powerline-fonts
        powerline-symbols
        roboto
        jetbrains-mono
        emacs-all-the-icons-fonts
        victor-mono
        iosevka
        _3270font
        nerdFonts
      ];
    };
  };
}

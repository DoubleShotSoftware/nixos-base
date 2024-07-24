{ config, pkgs, inputs, desktop, ... }:
let unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
in {
  homebrew = {
    enable = true;
    global = { lockfiles = true; };
    masApps = {
      Xcode = 497799835;
      "Unsplash Wallpapers" = 1284863847;
      "Microsoft Remote Desktop" = 1295203466;
      "WireGuard" = 1451685025;
    };
    brews = [
      "null-dev/firefox-profile-switcher/firefox-profile-switcher-connector"
      "sketchybar"
      "ical-buddy"
      "docker"
      "docker-compose"
      "docker-buildx"
      "gnu-getopt"
    ];
    casks = [
      { name = "spotify"; }
      { name = "tidal"; }
      { name = "nikitabobko/tap/aerospace"; }
      { name = "nikitabobko/tap/aerospace"; }
      { name = "gpg-suite"; }
      { name = "postman"; }
      { name = "kitty"; }
      { name = "jetbrains-toolbox"; }
      { name = "firefox"; }
      { name = "utm"; }
      { name = "wezterm"; }
      { name = "kitty"; }
      { name = "alacritty"; }
      { name = "graalvm/tap/graalvm-ce-java11"; }
      { name = "graalvm/tap/graalvm-ce-java17"; }
      { name = "temurin"; }
      { name = "font-3270-nerd-font"; }
      { name = "font-fira-mono-nerd-font"; }
      { name = "font-fira-code"; }
      { name = "font-fira-mono"; }
      { name = "font-fira-mono-for-powerline"; }
      { name = "font-fira-sans"; }
      { name = "font-fira-sans-condensed"; }
      { name = "font-fira-sans-extra-condensed"; }
      { name = "font-firago"; }
      { name = "font-inconsolata-go-nerd-font"; }
      { name = "font-inconsolata-lgc-nerd-font"; }
      { name = "font-inconsolata-nerd-font"; }
      { name = "font-monofur-nerd-font"; }
      { name = "font-overpass-nerd-font"; }
      { name = "font-ubuntu-mono-nerd-font"; }
      { name = "font-agave-nerd-font"; }
      { name = "font-arimo-nerd-font"; }
      { name = "font-anonymice-nerd-font"; }
      { name = "font-aurulent-sans-mono-nerd-font"; }
      { name = "font-bigblue-terminal-nerd-font"; }
      { name = "font-bitstream-vera-sans-mono-nerd-font"; }
      { name = "font-blex-mono-nerd-font"; }
      { name = "font-caskaydia-cove-nerd-font"; }
      { name = "font-code-new-roman-nerd-font"; }
      { name = "font-cousine-nerd-font"; }
      { name = "font-daddy-time-mono-nerd-font"; }
      { name = "font-dejavu-sans-mono-nerd-font"; }
      { name = "font-droid-sans-mono-nerd-font"; }
      { name = "font-fantasque-sans-mono-nerd-font"; }
      { name = "font-fira-code-nerd-font"; }
      { name = "font-go-mono-nerd-font"; }
      { name = "font-gohufont-nerd-font"; }
      { name = "font-hack-nerd-font"; }
      { name = "font-hasklug-nerd-font"; }
      { name = "font-heavy-data-nerd-font"; }
      { name = "font-hurmit-nerd-font"; }
      { name = "font-im-writing-nerd-font"; }
      { name = "font-iosevka-nerd-font"; }
      { name = "font-jetbrains-mono-nerd-font"; }
      { name = "font-jetbrains-mono"; }
      { name = "font-lekton-nerd-font"; }
      { name = "font-liberation-nerd-font"; }
      { name = "font-meslo-lg-nerd-font"; }
      { name = "font-monoid-nerd-font"; }
      { name = "font-mononoki-nerd-font"; }
      { name = "font-mplus-nerd-font"; }
      { name = "font-noto-nerd-font"; }
      { name = "font-open-dyslexic-nerd-font"; }
      { name = "font-profont-nerd-font"; }
      { name = "font-proggy-clean-tt-nerd-font"; }
      { name = "font-roboto-mono-nerd-font"; }
      { name = "font-sauce-code-pro-nerd-font"; }
      { name = "font-shure-tech-mono-nerd-font"; }
      { name = "font-space-mono-nerd-font"; }
      { name = "font-terminess-ttf-nerd-font"; }
      { name = "font-tinos-nerd-font"; }
      { name = "font-ubuntu-nerd-font"; }
      { name = "font-victor-mono-nerd-font"; }
      { name = "sf-symbols"; }
    ];
    taps = [
      "FelixKratz/formulae"
      "null-dev/firefox-profile-switcher"
      "homebrew/bundle"
    ];
  };
}

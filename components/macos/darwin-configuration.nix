{
  lib,
  config,
  pkgs,
  constants ? import ../../models/constants.nix,
  ...
}:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableBashCompletion = true;
    enableFzfCompletion = true;
    enableFzfGit = true;
  };
  nix.enable = true;
  nixpkgs.config.allowUnsupportedSystem = true;
  system.stateVersion = constants.darwinStateVersion;
  environment.systemPackages = with pkgs; [
    coreutils
    procps  # GNU ps command
  ];

  # Enable Touch ID for sudo
  security.pam.services.sudo_local.touchIdAuth = true;
  system.defaults = {
    screencapture = {
      location = "/tmp";
    };
    dock = {
      autohide = true;
      showhidden = true;
      mru-spaces = false;
    };
    finder = {
      AppleShowAllExtensions = true;
      AppleShowAllFiles = true;
      CreateDesktop = false;
      FXPreferredViewStyle = "Nlsv";
      FXEnableExtensionChangeWarning = true;
      QuitMenuItem = true;
      ShowPathbar = true;
      ShowStatusBar = true;
      _FXShowPosixPathInTitle = true;

    };
    NSGlobalDomain = {
      AppleKeyboardUIMode = 3;
      ApplePressAndHoldEnabled = false;
      AppleFontSmoothing = 1;
      _HIHideMenuBar = false;
      InitialKeyRepeat = 10;
      "com.apple.mouse.tapBehavior" = 1;
      "com.apple.swipescrolldirection" = true;
    };
  };
}

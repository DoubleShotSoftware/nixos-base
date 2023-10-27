{ config, pkgs, lib, ... }:
with lib;
with builtins;
let
  users = config.personalConfig.users;
  desktopEnabled = any
    (userConfig: userConfig.desktop != "disabled")
    (
      mapAttrsToList (user: userConfig: userConfig) users
    );
in
{

  config = lib.mkIf desktopEnabled {
    security.rtkit.enable = true;
    hardware.pulseaudio.enable = false;
    environment.systemPackages = with pkgs; [ pavucontrol ];
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };
}


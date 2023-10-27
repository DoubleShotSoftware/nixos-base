{ config, lib, pkgs, ... }:
let unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
in {
  services = {
    syncthing = {
      enable = true;
      user = "sobrien";
      dataDir = "/persist/SyncThing";
      configDir = "/persist/syncthing/config";
      overrideDevices =
        true; # overrides any devices added or deleted through the WebUI
      overrideFolders =
        true; # overrides any folders added or deleted through the WebUI
      devices = {
        "nas" = {
          id =
            "MBPZZI2-EYV7AMX-EY5CNZQ-FPBC6D5-ZXK2R4C-CA4UOZH-UN2LTJM-TKIT2AI";
        };
        "inspiron16" = {
          id =
            "A3RRCHH-FVLRDU6-W3E5TZ4-3RJI2KR-YJNKOW7-U7TWWIB-R4WFEHG-PAOE2Q3";
        };
      };
      folders = {
        "MozillaProfiles" = {
          path = "/home/sobrien/.mozilla";
          devices = [ "nas" "inspiron16" ];
        };
        "WorkspacesCommon" = {
          path = "/home/workspaces/common/";
          devices = [ "nas" "inspiron16" ];
          ignorePerms = false;
        };
        "WorkspacesAteam" = {
          path = "/home/workspaces/ateam.internal";
          devices = [ "nas" "inspiron16" ];
          ignorePerms = false;
        };
        "WorkspacesWallaroo" = {
          path = "/home/workspaces/wallaroo";
          devices = [ "nas" "inspiron16" ];
          ignorePerms = false;
        };
      };
    };
  };
}

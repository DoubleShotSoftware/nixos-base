{ config, lib, options, pkgs, ... }:
with lib;
let
  tzdir = "${pkgs.tzdata}/share/zoneinfo";
  nospace = str: filter (c: c == " ") (stringToCharacters str) == [ ];
  timezone = types.nullOr (types.addCheck types.str nospace) // {
    description = "null or string without spaces";
  };

in {
  imports = [ ];
  options.personalConfig = with lib; {
    system = {
      nixStateVersion = mkOption {
        type = types.str;
        default = "24.11";
        description =
          "The nixos state version to use, also used for home-manager";
      };
      darwinStateVersion = mkOption {
        type = types.int;
        default = 4;
        description =
          "The nixos state version to use, also used for home-manager";
      };
      timeZone = mkOption {
        default = "America/New_York";
        type = timezone;
        example = "America/New_York";
        description = lib.mdDoc ''
          The time zone used when displaying times and dates. See <https://en.wikipedia.org/wiki/List_of_tz_database_time_zones>
          for a comprehensive list of possible values for this setting.

          If null, the timezone will default to UTC and can be set imperatively
          using timedatectl.
        '';
      };
    };
  };
  config = lib.mkMerge [
    (lib.mkIf (pkgs.system != "aarch64-darwin") {
      system.stateVersion = config.personalConfig.system.nixStateVersion;
      environment.systemPackages = with pkgs; [ usbutils nfs-utils pciutils cryptsetup openssl ];
      programs.nix-ld = {
        enable = true;
        libraries = with pkgs; [
          stdenv.cc.cc
          zlib
          fuse3
          icu
          nss
          openssl
          curl
          expat
          libgcc
          libllvm
        ];

      };
    })
    (lib.mkIf (pkgs.system == "aarch64-darwin") {
      system.stateVersion = config.personalConfig.system.darwinStateVersion;
    })
    {
      time.timeZone = config.personalConfig.system.timeZone;
      nixpkgs.config.allowUnfree = true;
      environment.systemPackages = with pkgs; [
        unstable.jujutsu
        nix-output-monitor
        sops
        age
        gnumake
        screen
        cmake
        tmux
        vim
        curl
        wget
        git
        htop
        zsh
        rsync
        nixfmt
        p7zip
        jq
        nixfmt
        gnupg
        tree
        pwgen
      ];
      nix = {
        #settings.auto-optimise-store = true;
        gc = { automatic = true; };
        extraOptions = ''
          experimental-features = nix-command flakes
          keep-outputs = true
          keep-derivations = true
        '';
      };
    }
  ];
}

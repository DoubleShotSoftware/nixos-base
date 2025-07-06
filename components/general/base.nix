{ config, lib, options, pkgs, constants ? import ../../models/constants.nix, ...
}:
with lib;
let tzdir = "${pkgs.tzdata}/share/zoneinfo";
in {
  imports = [ ];
  config = lib.mkMerge [
    (lib.mkIf (pkgs.stdenv.isDarwin) {
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
        nixfmt-rfc-style
        p7zip
        jq
        deploy-rs
        gnupg
        tree
        pwgen
      ];
      nix = {
        optimise.automatic = true;
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

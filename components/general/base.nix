{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  imports = [];
  config = lib.mkMerge [
    (lib.mkIf (pkgs.stdenv.isDarwin) {
      system.stateVersion = config.personalConfig.system.darwinStateVersion;
    })
    {
      time.timeZone = config.personalConfig.system.timeZone;
      nixpkgs.config.allowUnfree = true;
      environment.systemPackages = with pkgs;
        [
          dust
          yazi
          unstable.jujutsu
          broot
          btop
          nix-output-monitor
          sops
          age
          screen
          vim
          curl
          wget
          git
          htop
          rsync
          p7zip
          jq
          deploy-rs
          gnupg
          tree
          pwgen
          ssh-to-age
        ]
        ++ lib.optionals config.personalConfig.system.developerPackages [
          gnumake
          cmake
        ];
      nix = {
        optimise.automatic = true;
        gc = {
          automatic = true;
        };
        extraOptions = ''
          experimental-features = nix-command flakes
          keep-outputs = true
          keep-derivations = true
          !include /etc/nix/access-tokens
        '';
      };
    }
  ];
}

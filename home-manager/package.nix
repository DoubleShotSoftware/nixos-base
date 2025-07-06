# Function to build home-manager configurations
{ nixpkgs
, nixpkgs-unstable
, home-manager
, sops-nix
, nix-index-database
, nixgl
, system
, nvim-ide ? null
}:
let
  pkgs = nixpkgs.legacyPackages.${system};
  
  overlay-unstable = final: prev: {
    unstable = import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };
  };
  
  overlay-nvim-ide = final: prev: 
    if nvim-ide != null then {
      nvim-ide = nvim-ide.packages.${system}.default;
    } else {};
  
  overlay-nixgl = nixgl.overlay;
  
  defaultModules = [
    ({ ... }: {
      nixpkgs.overlays = [ 
        overlay-unstable 
        overlay-nixgl 
        overlay-nvim-ide 
      ];
    })
    sops-nix.homeManagerModules.sops
    nix-index-database.hmModules.nix-index
  ];

  constants = import ../models/constants.nix;
  
  mkHomeConfiguration = { personalConfig, extraModules ? [] }:
    home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        ../models
        ./.
        ../components/languages
        {
          inherit personalConfig;
          _module.args.constants = constants;
        }
      ] ++ defaultModules ++ extraModules;
    };
in
{
  # Default configuration for sobrien
  sobrien = mkHomeConfiguration { 
    personalConfig = {
      system.nixStateVersion = constants.nixStateVersion;
      users.sobrien = {
        desktop = "gnome";
        userType = "normal";
      };
    };
  };
  
  # Function to create custom configurations
  inherit mkHomeConfiguration;
}
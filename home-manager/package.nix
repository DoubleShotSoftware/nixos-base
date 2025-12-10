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
  
  overlay-nvim-ide = final: prev: {};
  
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
        ({ ... }: {
          _module.args = {
            inherit constants personalConfig;
          };
        })
        ../components/languages/home-manager.nix
        {
          inherit personalConfig;
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
        languages = [ "typescript" "python" ];
        shell = "zsh";
      };
    };
  };
  
  # Function to create custom configurations
  inherit mkHomeConfiguration;
}
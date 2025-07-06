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

  mkHomeConfiguration = { username, extraModules ? [], homeConfig ? {} }:
    home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        ./.
        {
          homeConfig = {
            inherit username;
            isNixOs = false;
            gnome.enable = false;
          } // homeConfig;
        }
      ] ++ defaultModules ++ extraModules;
    };
in
{
  # Default configuration for sobrien
  sobrien = mkHomeConfiguration { 
    username = "sobrien";
    homeConfig = {
      gnome.enable = true;
    };
  };
  
  # Function to create custom configurations
  inherit mkHomeConfiguration;
}
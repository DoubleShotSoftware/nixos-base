{

  description = "Platform Craft Common Nix Config.";
  inputs = {
    nixgl.url = "github:nix-community/nixGL";
    nixpkgs.url = "nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    microvm = {
      url = "github:astro/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur.url = "github:nix-community/NUR";
    sops-nix.url = "github:Mic92/sops-nix";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    deploy-rs.url = "github:serokell/deploy-rs";
    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, nixpkgs-unstable, nixos-hardware, home-manager, nur
    , sops-nix, nix-darwin, nixvim, flake-parts, nixgl, nix-index-database, ... }:
    let
      constants = import ./constants.nix;
      system = (builtins.readFile ./system.ignore);
      hostPlatform = nixpkgs.lib.mkDefault system;
      forAllSystems = nixpkgs.lib.genAttrs constants.supportedSystems;
    in {
      nixosModules = {
        Common = ./components/general;
        Linux = ./components/linux;
        MacOs = ./components/macos;
        Languages = ./components/languages;
        HomeManager = { config, lib, pkgs, ... }: 
          import ./home-manager/nixos-module.nix {
            inherit config lib pkgs constants nix-index-database;
          };
        # Convenience module that includes Common + overlay
        CommonWithOverlay = { config, lib, pkgs, ... }: {
          imports = [ ./components/general ];
          nixpkgs.overlays = [ self.overlays.default ];
        };
      };
      
      homeManagerModules = {
        default = import ./home-manager;
        # Convenience module that includes default + overlay for standalone use
        withOverlay = { config, lib, pkgs, ... }: {
          imports = [ ./home-manager ];
          nixpkgs.overlays = [ self.overlays.default ];
        };
      };

      packages = forAllSystems (system:
        let
          nixvimPackages = import ./nixvim/package.nix {
            inherit nixpkgs nixpkgs-unstable nixvim system;
          };
        in {
          nixvim = nixvimPackages.default;
          nixvim-lite = nixvimPackages.lite;
        });
        
      overlays = {
        default = final: prev: {
          nvim-ide = self.packages.${prev.system}.nixvim;
          nvim-ide-lite = self.packages.${prev.system}.nixvim-lite;
        };
      };
      
      homeConfigurations = forAllSystems (system:
        let
          homePackages = import ./home-manager/package.nix {
            inherit nixpkgs nixpkgs-unstable home-manager sops-nix 
                    nix-index-database nixgl system;
            nvim-ide = nixvim;
          };
        in {
          sobrien = homePackages.sobrien;
        }
      );
    };
}

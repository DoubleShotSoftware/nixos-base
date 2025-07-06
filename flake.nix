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
      system = (builtins.readFile ./system.ignore);
      hostPlatform = nixpkgs.lib.mkDefault system;
      forAllSystems = nixpkgs.lib.genAttrs [
        "aarch64-linux"
        "i686-linux"
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
    in {
      nixosModules = {
        Common = import ./components/general;
        Linux = import ./components/linux;
        MacOs = import ./components/macos;
        Languages = import ./components/languages;
        Homemanager = import ./home-manager;
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

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
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, nixpkgs-unstable, nixos-hardware, home-manager, nur
    , sops-nix, nix-darwin, nixvim, flake-parts, nixgl, nix-index-database, nixos-generators, ... }:
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
      
      # Import custom packages
      customPackages = import ./packages;
    in {
      nixosModules = {
        Models = import ./models;
        Common = { pkgs, ... }: {
          imports = [ 
            ./models
            ./components/general
          ];
          nixpkgs.overlays = [ self.overlays.default ];
        };
        Linux = import ./components/linux;
        MacOs = import ./components/macos;
        HomeManager = { config, lib, pkgs, ... }: {
          imports = [ 
            ./home-manager/nixos-module.nix
          ];
          _module.args.nix-index-database = nix-index-database;
        };
        Languages = import ./components/languages/nixos.nix;
        CommonWithOverlay = { pkgs, ... }: {
          imports = [ self.nixosModules.Common ];
          nixpkgs.overlays = [ self.overlays.default ];
        };
      };
      
      homeManagerModules = {
        default = import ./home-manager;
        languages = import ./components/languages/home-manager.nix;
        withOverlay = { pkgs, ... }: {
          imports = [ self.homeManagerModules.default ];
          nixpkgs.overlays = [ self.overlays.default ];
        };
      };

      packages = forAllSystems (system:
        let
          nixvimPackages = import ./nixvim/package.nix {
            inherit nixpkgs nixpkgs-unstable nixvim system;
          };
          
          # Factory image builder function
          buildFactory = format: nixos-generators.nixosGenerate {
            inherit system format;
            modules = [ 
              ./factory-base
              sops-nix.nixosModules.sops
            ];
          };
        in {
          nixvim = nixvimPackages.default;
          nixvim-lite = nixvimPackages.lite;
          
          # Factory base images in various formats
          factory-base = buildFactory "qcow-efi";      # Default: QEMU/KVM with UEFI
          factory-qcow = buildFactory "qcow";          # QEMU/KVM with BIOS
          factory-raw = buildFactory "raw-efi";        # Raw disk image (convertible)
          factory-hyperv = buildFactory "hyperv";      # Hyper-V VHDX format
          factory-vmware = buildFactory "vmware";      # VMware VMDK format
          factory-virtualbox = buildFactory "virtualbox"; # VirtualBox VDI format
          
          # Cloud provider formats
          factory-openstack = buildFactory "openstack"; # OpenStack QCOW2
          factory-proxmox = buildFactory "proxmox";     # Proxmox VMA format
          
          # Test VM (QCOW2 with UEFI)
          factory-test = nixos-generators.nixosGenerate {
            inherit system;
            format = "qcow-efi";
            modules = [ 
              ./factory-base/test/example-vm.nix
              sops-nix.nixosModules.sops
            ];
          };
        });
        
      overlays = {
        default = final: prev: {
          nvim-ide = self.packages.${prev.system}.nixvim;
          nvim-ide-lite = self.packages.${prev.system}.nixvim-lite;
          unstable = import nixpkgs-unstable {
            system = prev.system;
            config = prev.config;
          };
        } // (customPackages { pkgs = final; });
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

{
  description = "Platform Craft Common Nix Config.";
  inputs = {
    nixgl.url = "github:nix-community/nixGL";
    nixpkgs.url = "nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur.url = "github:nix-community/NUR";
    sops-nix.url = "github:Mic92/sops-nix";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    deploy-rs.url = "github:serokell/deploy-rs";
    darwin = {
      url = "github:LnL7/nix-darwin?ref=nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim/nixos-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixCats = {
      url = "github:BirdeeHub/nixCats-nvim";
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
  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    nixos-hardware,
    home-manager,
    nur,
    sops-nix,
    nix-darwin,
    nixvim,
    nixCats,
    flake-parts,
    nixgl,
    nix-index-database,
    nixos-generators,
    ...
  }: let
    system = builtins.readFile ./system.ignore;
    hostPlatform = nixpkgs.lib.mkDefault system;
    forAllSystems = nixpkgs.lib.genAttrs [
      "aarch64-linux"
      "i686-linux"
      "x86_64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
    ];

    # Define Linux-only systems for nixos-generators
    linuxSystems = [
      "aarch64-linux"
      "i686-linux"
      "x86_64-linux"
    ];

    # Import custom packages
    customPackages = import ./packages;

    # Import nixcats builder
    nixcatsLib = import ./nixcats {
      inherit nixpkgs nixpkgs-unstable nixCats;
    };
  in {
    nixosModules = {
      Models = import ./models;
      Common = {pkgs, ...}: {
        imports = [
          ./models
          ./components/general
        ];
        nixpkgs.overlays = [self.overlays.default];
      };
      Linux = import ./components/linux;
      MacOs = import ./components/macos;
      HomeManager = {
        config,
        lib,
        pkgs,
        ...
      }: {
        imports = [
          ./home-manager/nixos-module.nix
        ];
        _module.args.nix-index-database = nix-index-database;
      };
      Languages = import ./components/languages/nixos.nix;
      CommonWithOverlay = {pkgs, ...}: {
        imports = [self.nixosModules.Common];
        nixpkgs.overlays = [self.overlays.default];
      };
    };

    homeManagerModules = {
      default = import ./home-manager;
      languages = import ./components/languages/home-manager.nix;
      withOverlay = {pkgs, ...}: {
        imports = [self.homeManagerModules.default];
        nixpkgs.overlays = [self.overlays.default];
      };
    };

    packages = forAllSystems (
      system: let
        allLanguages = ["nix" "dotnet" "rust" "python" "typescript" "json" "sql" "terraform" "aws" "kotlin"];
        # Unstable pkgs with overlay applied (single source of truth for config)
        unstablePkgs = import nixpkgs-unstable {
          inherit system;
          config = {
            allowUnfree = true;
            permittedInsecurePackages = [
              "dotnet-sdk-6.0.428"
              "dotnet-sdk-7.0.410"
            ];
          };
          overlays = [self.overlays.default];
        };

        # Stable pkgs for packages that need stability
        stablePkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

        # Use dotnetSDK and customVimPlugins from overlay
        dotnetSDK = unstablePkgs.dotnetSDK;
        customVimPlugins = unstablePkgs.customVimPlugins;

        nixvimPackages = import ./nixvim/package.nix {
          inherit
            nixpkgs
            nixpkgs-unstable
            nixvim
            system
            dotnetSDK
            customVimPlugins
            ;
        };

        # Import standard nixpkgs for custom packages (without overlay to avoid recursion)
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

        pkgsForNixcats = unstablePkgs;

        # nixCats packages - pass pre-configured pkgs
        nixcatsPackages =
          {
            nixcats = nixcatsLib.mkNixCats {
              inherit system stablePkgs;
              pkgs = pkgsForNixcats;
              languages = ["nix"];
            };
            nixcats-full = nixcatsLib.mkNixCats {
              inherit system stablePkgs;
              pkgs = pkgsForNixcats;
              languages = allLanguages;
            };
            nixcats-dev = nixcatsLib.mkNixCats {
              inherit system stablePkgs;
              pkgs = pkgsForNixcats;
              languages = ["nix"];
              wrapRc = false;
            };
        }
        // builtins.listToAttrs (map (v: {
              name = "nixcats-${v}";
              value = nixcatsLib.mkNixCats {
                inherit system stablePkgs;
                pkgs = pkgsForNixcats;
                languages = ["nix" v];
                wrapRc = false;
              };
            })
            allLanguages);

        # Base packages available on all systems
        basePackages =
          {
            nixvim = nixvimPackages.default;
            nixvim-lite = nixvimPackages.lite;
          }
          // nixcatsPackages // (customPackages {inherit pkgs dotnetSDK;});
      in
        basePackages
    );

    overlays = {
      default = final: prev: let
        unstable = import nixpkgs-unstable {
          system = prev.system;
          config = {
            allowUnfree = prev.config.allowUnfree or false;
            permittedInsecurePackages =
              (prev.config.permittedInsecurePackages or [])
              ++ [
                "dotnet-sdk-6.0.428"
                "dotnet-sdk-7.0.410"
              ];
          };
        };
        # Centralized dotnet SDK configuration
        dotnetSDK = unstable.dotnetCorePackages.combinePackages ([
            unstable.dotnet-sdk_6
            unstable.dotnet-sdk_7
          ]
          ++ (with unstable.dotnetCorePackages; [
            sdk_8_0-bin
            sdk_9_0-bin
            sdk_10_0-bin
          ]));
      in
        {
          inherit unstable dotnetSDK;
          # Custom vim plugins shared between nixvim and nixcats
          customVimPlugins = import ./packages/vimPlugins {pkgs = unstable;};

          # Dynamic nixcats builder - builds slim editor with only specified languages
          # Usage: pkgs.mkNixCatsIDE { languages = ["dotnet" "typescript"]; }
          mkNixCatsIDE = {
            languages ? [],
            theme ? "catppuccin",
            wrapRc ? true,
            extraCategories ? {},
            extraPlugins ? [],
            extraPackages ? [],
          }: let
            # Keep NixCats on the unstable Neovim base, but merge in the
            # repo's custom package set so language modules can see
            # kotlin-lsp and the other overlay-defined helpers.
            pkgsForNixcats =
              unstable
              // {
                # NixCats expects this attrset for shared plugin inputs.
                customVimPlugins = import ./packages/vimPlugins {pkgs = unstable;};
                # Language modules (e.g. nixcats/languages/dotnet.nix) read
                # `pkgs.dotnetSDK` directly; surface it here since `unstable`
                # is imported without the overlay applied.
                inherit dotnetSDK;
              }
              // (customPackages {
                pkgs = final;
                inherit dotnetSDK;
              });
          in
            nixcatsLib.mkNixCats {
              system = prev.system;
              pkgs = pkgsForNixcats;
              stablePkgs = prev;
              languages = ["nix"] ++ languages; # always include nix
              inherit theme wrapRc extraCategories extraPlugins extraPackages;
            };
        }
        // (customPackages {
          pkgs = final;
          inherit dotnetSDK;
        });
    };

    homeConfigurations = forAllSystems (
      system: let
        homePackages = import ./home-manager/package.nix {
          inherit
            nixpkgs
            nixpkgs-unstable
            home-manager
            sops-nix
            nix-index-database
            nixgl
            system
            ;
          nvim-ide = nixvim;
        };
      in {
        sobrien = homePackages.sobrien;
      }
    );

    # Export nixcats lib for per-project use
    # Usage: inputs.nixos-base.lib.mkNixCats { system = "x86_64-linux"; languages = ["dotnet"]; }
    lib = {
      inherit (nixcatsLib) mkNixCats;
    };
  };
}

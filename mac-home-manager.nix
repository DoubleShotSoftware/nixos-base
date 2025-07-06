{
  description = "Home Manager configuration using nixos-base";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # Pull in nixos-base for the Homemanager module
    nixos-base = {
      url = "github:DoubleShotSoftware/nixos-base/25_05";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-unstable.follows = "nixpkgs-unstable";
    };
    
    # These are required by nixos-base's Homemanager module
    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    sops-nix.url = "github:Mic92/sops-nix";
    
    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    flake-utils = { url = "github:numtide/flake-utils"; };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, nixos-base,
              nix-index-database, sops-nix, nixgl, flake-utils, ... }:
    let
      # Change this to your Mac's architecture
      system = "aarch64-darwin"; # or "x86_64-darwin" for Intel Macs
      
      pkgs = nixpkgs.legacyPackages.${system};
      lib = nixpkgs.lib;
      
      # Additional overlays (nixos-base overlay is included via withOverlay)
      additionalOverlays = [
        # nixGL overlay for graphics support
        nixgl.overlay
        
        # Unstable overlay
        (final: prev: {
          unstable = import nixpkgs-unstable {
            inherit system;
            config.allowUnfree = true;
          };
        })
      ];
      
      # Common modules to include
      defaultModules = [
        # Apply additional overlays
        {
          nixpkgs.overlays = additionalOverlays;
          nixpkgs.config.allowUnfree = true;
        }
        
        # Modules from inputs
        sops-nix.homeManagerModules.sops
        nix-index-database.hmModules.nix-index
      ];
    in
    {
      homeConfigurations = {
        # Replace "sobrien" with your macOS username
        sobrien = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          
          modules = [
            # Import the home-manager module with overlay (for standalone use)
            # This brings in all the home-manager configuration AND nvim-ide
            nixos-base.homeManagerModules.withOverlay
            
            # Configuration for this machine
            {
              personalConfig = {
                system.nixStateVersion = "25.05";
                users.sobrien = {
                  desktop = "disabled"; # No desktop environment on macOS
                  userType = "normal";
                };
              };
              
              # macOS-specific home directory
              home.homeDirectory = lib.mkForce "/Users/sobrien"; # Change username
              
              # macOS-specific shell configuration
              programs.fish.interactiveShellInit = lib.mkAfter ''
                # Add homebrew to PATH if it exists
                if test -e /opt/homebrew/bin/brew
                  eval (/opt/homebrew/bin/brew shellenv)
                else if test -e /usr/local/bin/brew
                  eval (/usr/local/bin/brew shellenv)
                end
              '';
            }
          ] ++ defaultModules;
        };
      };
      
      # Convenience outputs for easier usage
      apps.${system} = {
        # Usage: nix run .#activate
        activate = {
          type = "app";
          program = "${self.homeConfigurations.sobrien.activationPackage}/activate";
        };
      };
      
      # Usage: nix build
      packages.${system}.default = self.homeConfigurations.sobrien.activationPackage;
    };
}

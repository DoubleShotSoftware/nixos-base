# Flake Integration for Custom Packages

This document describes the necessary changes to integrate the custom packages directory into your flake.nix.

## Required Changes to flake.nix

### 1. Import Custom Packages

Add custom packages import in the `let` block after the system definitions:

```nix
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
  
  # Add this line to import custom packages
  customPackages = import ./packages;
in {
```

### 2. Update the Overlay

Modify the `overlays.default` to include custom packages:

```nix
overlays = {
  default = final: prev: {
    nvim-ide = self.packages.${prev.system}.nixvim;
    nvim-ide-lite = self.packages.${prev.system}.nixvim-lite;
    unstable = import nixpkgs-unstable {
      system = prev.system;
      config = prev.config;
    };
    
    # Add custom packages to the overlay
    # This merges all custom packages into the overlay
  } // (customPackages { pkgs = final; });
};
```

### 3. Alternative: Direct Package Addition

If you prefer to add packages individually to the overlay:

```nix
overlays = {
  default = final: prev: 
    let
      pkgs = customPackages { pkgs = final; };
    in {
      nvim-ide = self.packages.${prev.system}.nixvim;
      nvim-ide-lite = self.packages.${prev.system}.nixvim-lite;
      unstable = import nixpkgs-unstable {
        system = prev.system;
        config = prev.config;
      };
      
      # Add specific packages
      resharper-cli = pkgs.resharper-cli;
    };
};
```

## Usage by Flake Consumers

Once integrated, consumers of your flake can access the custom packages in several ways:

### 1. Via Overlay

```nix
{
  inputs.your-flake.url = "github:your-org/nix-base";
  
  outputs = { self, nixpkgs, your-flake, ... }: {
    nixosConfigurations.example = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        {
          nixpkgs.overlays = [ your-flake.overlays.default ];
          environment.systemPackages = with pkgs; [
            resharper-cli
          ];
        }
      ];
    };
  };
}
```

### 2. Via NixOS Module

If using the Common module which includes the overlay:

```nix
{
  imports = [ your-flake.nixosModules.Common ];
  
  environment.systemPackages = with pkgs; [
    resharper-cli
  ];
}
```

## Adding New Packages

To add new custom packages:

1. Create a new `.nix` file in the `packages/` directory
2. Add an entry in `packages/default.nix`:
   ```nix
   {
     resharper-cli = pkgs.callPackage ./resharper-cli.nix { };
     your-new-package = pkgs.callPackage ./your-new-package.nix { };
   }
   ```
3. The package will automatically be available through the overlay

## Notes

- All custom packages are automatically included in the overlay
- Packages are built using the nixpkgs instance from the flake
- The overlay ensures packages are available to all NixOS and Home Manager configurations that use it
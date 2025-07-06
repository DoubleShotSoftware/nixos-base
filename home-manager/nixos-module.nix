# NixOS module wrapper for home-manager integration
{ config, lib, pkgs, constants, nix-index-database, ... }:
with lib;
let
  users = config.personalConfig.users;
in {
  # home-manager should be imported at the flake level, not here
  
  config = {
    # Set up home-manager for all "normal" users
    home-manager.users = mapAttrs (user: userConfig:
      mkIf (userConfig.userType == "normal") {
        imports = [ 
          ./.  # Import the actual home-manager module
          nix-index-database.hmModules.nix-index  # Import nix-index-database module
        ];
        
        # Pass configuration to the home-manager module
        homeConfig = {
          username = user;
          isNixOs = true;
          systemVersion = if (config.system ? stateVersion) then config.system.stateVersion else constants.defaultStateVersion;
          gnome.enable = userConfig.desktop == "gnome";  # Enable gnome if desktop is gnome
        };
      }
    ) users;
    
    # Use the system's pkgs by default
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
  };
}
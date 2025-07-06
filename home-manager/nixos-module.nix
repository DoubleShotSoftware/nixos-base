# NixOS module wrapper for home-manager integration
{ config, lib, pkgs, nix-index-database, ... }:
with lib;
let
  users = config.personalConfig.users;
  constants = import ../models/constants.nix;
in {
  # home-manager should be imported at the flake level, not here
  
  config = {
    # Set up home-manager for all "normal" users
    home-manager.users = mapAttrs (user: userConfig:
      mkIf (userConfig.userType == "normal") {
        imports = [ 
          ../models
          ./default.nix
          ../components/languages
          nix-index-database.hmModules.nix-index
        ];
        
        # Set the username so the home-manager module knows which user config to use
        home.username = user;
        
        # Pass through constants
        _module.args.constants = constants;
      }
    ) users;
    
    # Use the system's pkgs by default
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
  };
}
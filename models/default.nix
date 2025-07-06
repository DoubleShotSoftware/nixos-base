{ config, lib, options, pkgs, ... }:
with lib;
let
  constants = import ./constants.nix;
  userOptions = import ./user.nix { inherit lib; };
  systemOptions = import ./system.nix { inherit lib; };
  machineOptions = import ./machine.nix { inherit lib; };
in
{
  imports = [ ];
  
  options.personalConfig = {
    users = mkOption {
      default = { };
      type = types.attrsOf (types.submodule userOptions);
      description = "Configure users.";
    };
    
    system = systemOptions.options;
    
    inherit (machineOptions.options) machineType;
  };
  
  # Export constants for use by other modules
  config._module.args.constants = constants;
}
{ config, lib, options, pkgs, ... }:
with lib;
let
  constants = import ./constants.nix;
  userOptions = import ./user.nix { inherit lib; };
  systemOptions = import ./system.nix { inherit lib; };
  networkingOptions = import ./networking.nix { inherit lib; };
  cockpitOptions = import ./cockpit.nix { inherit lib; };
  libvirtOptions = import ./libvirt.nix { inherit lib; };
  firecrackerOptions = import ./firecracker.nix  { inherit lib; };
  languageSettingsOptions = import ./languageSettings.nix { inherit lib; };
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

    networking = networkingOptions.options.personalConfig.networking;

    constants = networkingOptions.options.personalConfig.constants;

    inherit (cockpitOptions.options) cockpit;

    inherit (libvirtOptions.options) linux;
    inherit (firecrackerOptions.options) firecracker;

    languageSettings = languageSettingsOptions.options;
  };

  # Export constants for use by other modules
  config._module.args.constants = constants;
}

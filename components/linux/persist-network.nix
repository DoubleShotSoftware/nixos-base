{ config, lib, options, pkgs, ... }:
with lib;
let
  nicOptions = { ... }: {
    options = {
      name = mkOption {
        type = types.str;
        description = "friendly interface name";
        example = "lan";
      };
      mac = mkOption {
        type = types.str;
        description = "Mac address of device to rename";
      };
    };
  };
  nicUdevRules = map
    (nicConfig: ''
      SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="${nicConfig.mac}" NAME="${nicConfig.name}"
    '')
    config.personalConfig.linux.renameNics;
in
{
  options.personalConfig.linux.renameNics = mkOption {
    type = types.listOf (types.submodule nicOptions);
    default = [ ];
  };
  config =
    {
      services.udev.extraRules = lib.concatStringsSep "\n" nicUdevRules;
    };
}

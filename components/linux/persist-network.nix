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
  # DRIVERS=="?*" scopes the rename to physical ether devices (PCI/USB NICs
  # with a driver in their parent chain). Without it, this rule also matches
  # VLAN children (which inherit the parent NIC's MAC) and bridges (whose MAC
  # is often pinned to the same value via constants), causing rename
  # collisions like `lan.work → lan: File exists`.
  nicUdevRules = map
    (nicConfig: ''
      SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ATTR{address}=="${nicConfig.mac}", NAME="${nicConfig.name}"
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

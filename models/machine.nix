{ lib }:
with lib;
{
  options = {
    machineType = mkOption {
      type = types.enum [ "work" "personal" ];
      default = "personal";
      description = "Whether this instance is personal or work based, personal includes more personal related packages.";
    };
  };
}
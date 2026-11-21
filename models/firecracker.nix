{ lib }:
with lib;
{
  options = {
    firecracker = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable firecracker virtualization support.
        '';
      };
    };
  };
}

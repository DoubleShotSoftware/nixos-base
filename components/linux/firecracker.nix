{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.personalConfig.linux.libvirt;
in
{
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      firecracker
      firectl
    ];
  };

}

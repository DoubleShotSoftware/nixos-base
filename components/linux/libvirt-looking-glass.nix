{ config, pkgs, lib, ... }:

with lib;
let
  cfg = config.personalConfig.linux.libvirt.lookingGlass;
  libvirtCfg = config.personalConfig.linux.libvirt;

  # Documented Looking Glass framebuffer sizes (power-of-two MiB) keyed by the
  # resolution enum. width*height*4*2 rounded up to the next power of two; see
  # https://looking-glass.io/docs/B7/install/#determining-memory
  sizeMB = {
    "1080p" = 32;
    "1440p" = 64;
    "1600p" = 64;
    "4k" = 128;
  }.${cfg.resolution};

  useKvmfr = cfg.transport == "kvmfr";
in
{
  config = mkIf (libvirtCfg.enable && cfg.enable) (mkMerge [
    {
      assertions = [
        {
          assertion = config.virtualisation.libvirtd.enable;
          message = "Looking Glass requires libvirtd. Set personalConfig.linux.libvirt.enable = true;";
        }
      ];
      # The host client (renders the captured guest framebuffer in a window).
      environment.systemPackages = [ pkgs.looking-glass-client ];
    }

    # kvmfr: DMABUF kernel module, /dev/kvmfr0 mapped directly by the client.
    # static_size_mb is reserved from normal kernel memory at module load,
    # independent of any guest hugepages.
    #
    # extraModulePackages / kernelModules are listOf — they list-concatenate
    # with the host's kernel.nix defs (no overwrite, order irrelevant).
    # extraModprobeConfig is the `lines` type: it newline-joins with the
    # host block; mkAfter pins our line *after* it so a future `options kvmfr`
    # collision would resolve in our favour regardless of import order.
    (mkIf useKvmfr {
      boot.extraModulePackages = [ config.boot.kernelPackages.kvmfr ];
      boot.kernelModules = [ "kvmfr" ];
      boot.extraModprobeConfig =
        lib.mkAfter "options kvmfr static_size_mb=${toString sizeMB}";
      # The module creates the /dev/kvmfr0 char device itself; udev only
      # adjusts ownership so qemu (group qemu-libvirtd) can map it.
      services.udev.extraRules = ''
        SUBSYSTEM=="kvmfr", OWNER="${cfg.user}", GROUP="qemu-libvirtd", MODE="0660"
      '';
    })

    # ivshmem: plain /dev/shm file fallback (the previously-working path).
    (mkIf (!useKvmfr) {
      systemd.tmpfiles.rules = [
        "f /dev/shm/looking-glass 0660 ${cfg.user} qemu-libvirtd -"
      ];
    })
  ]);
}

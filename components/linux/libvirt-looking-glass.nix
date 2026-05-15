{ config, pkgs, lib, ... }:

with lib;
let
  cfg = config.personalConfig.linux.libvirt.lookingGlass;
  libvirtCfg = config.personalConfig.linux.libvirt;

  # Documented Looking Glass framebuffer sizes (power-of-two MiB) keyed by the
  # resolution enum. width*height*4*2 rounded up to the next power of two; see
  # https://looking-glass.io/docs/B7/install/#determining-memory
  sizeMB = {
    "1080p" = 64;
    "1440p" = 128;
    "1600p" = 128;
    "4k" = 256;
  }.${cfg.resolution};

  useKvmfr = cfg.transport == "kvmfr";

  # kvmfr exposes /dev/kvmfr0; ivshmem uses the client default
  # (/dev/shm/looking-glass), so only the kvmfr path needs -f.
  lgExec = "looking-glass-client"
    + optionalString useKvmfr " -f /dev/kvmfr0";

  # "Home-manager is present for this user" == it's a personalConfig `normal`
  # user, because components/general/default.nix only populates
  # home-manager.users.<name> for `filterAttrs (userType != "system")`.
  hmUser =
    (config.personalConfig.users ? ${cfg.user})
    && (config.personalConfig.users.${cfg.user}.userType or "system") == "normal";

  desktopItem = pkgs.makeDesktopItem {
    name = "looking-glass";
    desktopName = "Looking Glass";
    genericName = "VM Display";
    comment = "Low-latency passthrough display (${cfg.transport}, ${cfg.resolution})";
    exec = lgExec;
    terminal = false;
    categories = [ "System" "Utility" ];
  };
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
      # The client itself. The launcher is added per-user via home-manager when
      # lookingGlass.user is a `normal` personalConfig user; otherwise a
      # system-wide .desktop is shipped so the launcher always exists.
      environment.systemPackages =
        [ pkgs.looking-glass-client ] ++ optional (!hmUser) desktopItem;
    }

    (mkIf hmUser {
      home-manager.users.${cfg.user}.xdg.desktopEntries.looking-glass = {
        name = "Looking Glass";
        genericName = "VM Display";
        comment = "Low-latency passthrough display (${cfg.transport}, ${cfg.resolution})";
        exec = lgExec;
        terminal = false;
        categories = [ "System" "Utility" ];
      };
    })

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

      # /dev/kvmfr0 reaches qemu only through a raw <qemu:commandline>
      # memory-backend-file, which libvirt never parses — so it is absent
      # from the per-domain *devices* cgroup it builds from the domain XML.
      # File mode 0660 is then irrelevant: the devices cgroup denies the
      # char-dev major outright and open() returns EPERM ("Operation not
      # permitted"), even for a root-run qemu. Re-declaring cgroup_device_acl
      # replaces libvirt's built-in default list wholesale, so the default
      # entries must be repeated verbatim alongside /dev/kvmfr0. Per-domain
      # VFIO/<hostdev> nodes are still added by libvirt itself and do not
      # belong here. verbatimConfig is `types.lines` (default
      # "namespaces = []"); mkAfter appends our block without clobbering it,
      # mirroring the extraModprobeConfig pattern above.
      virtualisation.libvirtd.qemu.verbatimConfig = lib.mkAfter ''
        cgroup_device_acl = [
          "/dev/null", "/dev/full", "/dev/zero",
          "/dev/random", "/dev/urandom",
          "/dev/ptmx", "/dev/kvm",
          "/dev/userfaultfd",
          "/dev/kvmfr0"
        ]
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

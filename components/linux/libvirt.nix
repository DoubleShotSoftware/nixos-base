{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.personalConfig.linux.libvirt;
  libvirt_users = cfg.userAllow;
in
{
  imports = [
    ./libvirt-mem-balloon.nix
    ./libvirt-ksm.nix
    ./libvirt-dbus.nix
    ./libvirt-looking-glass.nix
  ];

  config = mkIf cfg.enable (
    trace "Enabling lib virt." mkMerge [
      {
        security.polkit.enable = true;
        # Add polkit rule for libvirtd group (NixOS uses libvirtd, but upstream libvirt checks for libvirt)
        security.polkit.extraConfig = ''
          polkit.addRule(function(action, subject) {
            if (!subject.isInGroup("libvirtd")) {
              return;
            }
            // Interactive admins in the libvirtd group manage domains.
            if (action.id == "org.libvirt.unix.manage") {
              return polkit.Result.YES;
            }
            // Read-only consumers (the Prometheus libvirt exporter connects on
            // the -ro socket) get monitor without an interactive agent, so a
            // headless host stops logging auth-unavailable once per scrape.
            if (action.id == "org.libvirt.unix.monitor") {
              return polkit.Result.YES;
            }
          });
        '';
        virtualisation = {
          libvirtd = {
            enable = true;
            allowedBridges = [ "all" ];
            extraOptions = [
              "--verbose"
            ];
            qemu = {
              package = pkgs.qemu_kvm;
              swtpm = {
                enable = true;
              };
            };
          };
        };
        services.u9fs.enable = true;
        users.groups.libvirtd.members = libvirt_users;
        users.groups.qemu-libvirtd.members = libvirt_users;
        users.groups.kvm.members = libvirt_users;
        # OVMF images now auto-available at /run/libvirt/nix-ovmf (NixOS 25.11+)
      }
      # Looking Glass moved to ./libvirt-looking-glass.nix (common sub-module,
      # adds the performant KVMFR transport alongside the ivshmem fallback).
      (lib.mkIf cfg.zfsSupport {
        nixpkgs.config = {
          libvirt = {
            enableZfs = true;
          };
        };
      })
      (lib.mkIf cfg.bridgeSupport {
        boot.kernel.sysctl = {
          "net.ipv4.conf.all.forwarding" = 1;
          "net.ipv6.conf.all.forwarding" = 1;
          "net.bridge.bridge-nf-call-ip6tables" = 0;
          "net.bridge.bridge-nf-call-iptables" = 0;
          "net.bridge.bridge-nf-call-arptables" = 0;
        };
      })
      # The nixpkgs-generated u9fs.socket declares After=network.target, which
      # combined with sockets.target creates an ordering cycle that causes
      # systemd to silently drop NetworkManager.service from boot. A listening
      # socket doesn't need network routing, so strip the bogus After= — but
      # only on hosts that actually use NetworkManager (systemd-networkd hosts
      # don't hit this cycle).
      (lib.mkIf config.networking.networkmanager.enable {
        systemd.sockets.u9fs.unitConfig.After = lib.mkForce [ ];
      })
    ]
  );
}

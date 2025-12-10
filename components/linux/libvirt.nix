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
  ];

  config = mkIf cfg.enable (
    trace "Enabling lib virt." mkMerge [
      {
        security.polkit.enable = true;
        # Add polkit rule for libvirtd group (NixOS uses libvirtd, but upstream libvirt checks for libvirt)
        security.polkit.extraConfig = ''
          polkit.addRule(function(action, subject) {
            if (action.id == "org.libvirt.unix.manage" &&
                subject.isInGroup("libvirtd")) {
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
      (lib.mkIf cfg.lookingGlass.enable {
        systemd.tmpfiles.rules = [
          "f /dev/shm/looking-glass 0660 ${cfg.lookingGlass.user} qemu-libvirtd -"
        ];
        environment.systemPackages = with pkgs; [ looking-glass-client ];
      })
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
    ]
  );
}

{ config, lib, pkgs, inputs, desktop, ... }:
with lib;
let
  libvirt_users = [ "sobrien" "manager" ];
  cfg = config.personalConfig.linux.libvirt;
in
{
  options.personalConfig.linux.libvirt = with lib; {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to enable looking libvirt support.
      '';
    };
    lookingGlass.enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to enable looking glass support.
      '';
    };
    lookingGlass.user = mkOption {
      type = types.str;
      default = "manager";
      description = ''
        The user to create looking glass file as, default: manager.
      '';
    };
    zfsSupport = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to add zfs support to libvirt
      '';
    };
    bridgeSupport = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Add support for bridge network passthrough.
      '';
    };
  };
  config = mkIf cfg.enable
    (
      trace "Enabling lib virt."
        mkMerge [
        {
          security.polkit.enable = true;
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
                ovmf = {
                  enable = true;
                  packages = [ pkgs.OVMFFull.fd ];
                };
              };
            };
          };
          services.u9fs.enable = true;
          users.groups.libvirtd.members = libvirt_users;
          users.groups.qemu-libvirtd.members = libvirt_users;
          users.groups.kvm.members = libvirt_users;
          environment.etc = {
            "ovmf/edk2-x86_64-secure-code.fd" = {
              source = config.virtualisation.libvirtd.qemu.package + "/share/qemu/edk2-x86_64-secure-code.fd";
            };

            "ovmf/edk2-i386-vars.fd" = {
              source = config.virtualisation.libvirtd.qemu.package + "/share/qemu/edk2-i386-vars.fd";
            };
          };
        }
        (lib.mkIf cfg.lookingGlass.enable {
          systemd.tmpfiles.rules = [
            "f /dev/shm/looking-glass 0660 ${cfg.lookingGlass.user} qemu-libvirtd -"
          ];
          environment.systemPackages = with pkgs; [ looking-glass-client ];
        })
        (lib.mkIf cfg.zfsSupport
          {
            nixpkgs.config = { libvirt = { enableZfs = true; }; };
          })
        (lib.mkIf cfg.bridgeSupport
          {
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

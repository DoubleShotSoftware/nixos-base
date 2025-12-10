{ lib }:
with lib;
{
  options = {
    linux.libvirt = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable libvirt virtualization support.
        '';
      };

      lookingGlass = {
        enable = mkOption {
          type = types.bool;
          default = false;
          description = ''
            Whether to enable Looking Glass support for low-latency KVM GPU passthrough.
          '';
        };

        user = mkOption {
          type = types.str;
          default = "manager";
          description = ''
            The user to create looking glass shared memory file as.
          '';
        };
      };

      zfsSupport = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to add ZFS support to libvirt storage pools.
        '';
      };

      bridgeSupport = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Add support for bridge network passthrough.
        '';
      };

      dbus = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = ''
            Whether to enable libvirt D-Bus API service.
            Required for Cockpit Machines and other D-Bus clients.
          '';
        };
      };

      ksm = {
        enable = mkOption {
          type = types.bool;
          default = false;
          description = ''
            Enable Kernel Same-Page Merging (KSM) for memory deduplication.
            Useful for virtualization environments with multiple VMs.
          '';
        };

        pages_to_scan = mkOption {
          type = types.int;
          default = 1000;
          description = ''
            Number of pages to scan before sleeping (kernel default: 100).
            Higher values increase scan speed but use more CPU.
          '';
        };

        sleep_millisecs = mkOption {
          type = types.int;
          default = 20;
          description = ''
            Milliseconds to sleep between scans (kernel default: 20).
            Lower values scan faster but use more CPU.
          '';
        };

        merge_across_nodes = mkOption {
          type = types.bool;
          default = false;
          description = ''
            Whether to merge pages across NUMA nodes.
            Set to false to keep merging within same NUMA node for better latency.
          '';
        };

        use_zero_pages = mkOption {
          type = types.bool;
          default = true;
          description = ''
            Whether to merge empty pages with the kernel zero page.
            Recommended for better memory savings.
          '';
        };

        max_page_sharing = mkOption {
          type = types.int;
          default = 256;
          description = ''
            Maximum sharing sites per KSM page (minimum: 2, kernel default: 256).
          '';
        };

        smart_scan = mkOption {
          type = types.bool;
          default = true;
          description = ''
            Skip pages unlikely to merge (Linux 6.4+).
            Recommended for better performance.
          '';
        };
      };

      balloon = {
        enable = mkOption {
          type = types.bool;
          default = false;
          description = ''
            Enable automatic memory balloon management for VMs.
            Requires QEMU guest agent installed in VMs.
            Respects each VM's configured minimum memory from domain XML.
          '';
        };

        ignoreVMs = mkOption {
          type = types.listOf types.str;
          default = [ ];
          description = ''
            List of VM names to exclude from balloon management.
            All other running VMs will be managed automatically.
          '';
        };

        memoryStep = mkOption {
          type = types.int;
          default = 512;
          description = ''
            Memory adjustment step size in MB.
          '';
        };

        thresholds = {
          increase = mkOption {
            type = types.int;
            default = 70;
            description = ''
              Memory usage percentage threshold to trigger memory increase.
            '';
          };

          decrease = mkOption {
            type = types.int;
            default = 40;
            description = ''
              Memory usage percentage threshold to trigger memory decrease.
            '';
          };

          pressureMB = mkOption {
            type = types.int;
            default = 512;
            description = ''
              Available memory threshold in MB below which memory pressure is detected.
            '';
          };
        };

        delays = {
          increase = mkOption {
            type = types.int;
            default = 30;
            description = ''
              Minimum delay in seconds between memory increases.
            '';
          };

          decrease = mkOption {
            type = types.int;
            default = 300;
            description = ''
              Delay in seconds before decreasing memory after sustained low usage.
            '';
          };
        };

        timerInterval = mkOption {
          type = types.str;
          default = "30s";
          description = ''
            How often to run the balloon manager (systemd timer format).
          '';
        };
      };
    };
  };
}

{ config, pkgs, lib, ... }:

with lib;
let
  cfg = config.personalConfig.linux.libvirt.ksm;

  ksmConfigScript = pkgs.writeShellScriptBin "libvirt-ksm-config"
    (builtins.readFile ./libvirt-ksm.sh);

  ksmStopScript = pkgs.writeShellScript "libvirt-ksm-stop" ''
    #!/usr/bin/env bash
    set -euo pipefail

    # Stop KSM gracefully
    if [ -f /sys/kernel/mm/ksm/run ]; then
      echo 0 > /sys/kernel/mm/ksm/run
    fi
  '';
in {
  config = mkIf cfg.enable {
    systemd.services.ksm-config = {
      description = "Kernel Same-Page Merging Configuration";
      documentation = [ "https://docs.kernel.org/admin-guide/mm/ksm.html" ];
      wantedBy = [ "multi-user.target" ];
      after = [ "systemd-sysctl.service" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${ksmConfigScript}/bin/libvirt-ksm-config";
        ExecStop = "${ksmStopScript}";
      };

      environment = {
        PAGES_TO_SCAN = toString cfg.pages_to_scan;
        SLEEP_MILLISECS = toString cfg.sleep_millisecs;
        MERGE_ACROSS_NODES = if cfg.merge_across_nodes then "1" else "0";
        USE_ZERO_PAGES = if cfg.use_zero_pages then "1" else "0";
        MAX_PAGE_SHARING = toString cfg.max_page_sharing;
        SMART_SCAN = if cfg.smart_scan then "1" else "0";
      };
    };

    # Add helpful aliases for monitoring KSM
    environment.shellAliases = {
      ksm-status = "grep . /sys/kernel/mm/ksm/{run,pages_*,full_scans} 2>/dev/null";
      ksm-stats = ''
        echo "KSM Statistics:" && \
        echo "  Running: $(cat /sys/kernel/mm/ksm/run)" && \
        echo "  Pages Shared: $(cat /sys/kernel/mm/ksm/pages_shared)" && \
        echo "  Pages Sharing: $(cat /sys/kernel/mm/ksm/pages_sharing)" && \
        echo "  Saved MB: $(($(cat /sys/kernel/mm/ksm/pages_sharing) * 4 / 1024))" && \
        echo "  Full Scans: $(cat /sys/kernel/mm/ksm/full_scans)"
      '';
    };
  };
}

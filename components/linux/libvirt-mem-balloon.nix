{ config, pkgs, lib, ... }:

with lib;
let
  cfg = config.personalConfig.linux.libvirt.balloon;

  script = pkgs.writeShellScriptBin "libvirt-mem-balloon"
    (builtins.readFile ./libvirt-mem-balloon.sh);
in {
  config = mkIf cfg.enable {
    # Assertion to ensure libvirt is enabled
    assertions = [
      {
        assertion = config.virtualisation.libvirtd.enable;
        message = "Libvirt balloon memory manager requires libvirtd to be enabled. Set personalConfig.linux.libvirt.enable = true;";
      }
    ];

    systemd.services.libvirt-mem-balloon = {
      description = "Libvirt Memory Balloon Manager";
      after = [ "network.target" "libvirtd.service" ];
      wants = [ "libvirtd.service" ];
      serviceConfig = {
        ExecStart = "${script}/bin/libvirt-mem-balloon";
        User = "root";
        Type = "oneshot";
      };
      path = with pkgs; [ libvirt bash gawk jq coreutils ];
      environment = {
        LIBVIRT_DEFAULT_URI = "qemu:///system";
        HOME = "/root";

        # Pass configuration as environment variables
        IGNORE_VMS = concatStringsSep "," cfg.ignoreVMs;
        MEMORY_STEP_MB = toString cfg.memoryStep;
        THRESHOLD_UP = toString cfg.thresholds.increase;
        THRESHOLD_DOWN = toString cfg.thresholds.decrease;
        MEMORY_PRESSURE_MB = toString cfg.thresholds.pressureMB;
        INCREASE_DELAY = toString cfg.delays.increase;
        DECREASE_DELAY = toString cfg.delays.decrease;
      };
    };

    systemd.timers.libvirt-mem-balloon = {
      description = "Timer for Libvirt Memory Balloon Manager";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "30s";
        OnUnitActiveSec = cfg.timerInterval;
        Unit = "libvirt-mem-balloon.service";
      };
    };
  };
}

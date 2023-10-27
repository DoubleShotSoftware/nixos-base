{ config, lib, options, pkgs, ... }:
with lib;
with builtins;
let
  zreplJobOptions = { ... }: {
    options = {
      name = mkOption {
        type = types.str;
        description = "the name of the job.";
      };
      destination = mkOption {
        type = types.str;
        description = "A FQDN for the recipient of the snapshots.";
      };
      port = mkOption {
        type = types.int;
        description = "The port for the target server.";
      };
      tlsCa = mkOption {
        type = types.str;
        description = "The path to certificate authority cert";
        default = /etc/zrepl/tls/host.crt;
      };
      tlsHostKey = mkOption {
        type = types.path;
        description = "The path to certificate authority cert";
      };
      tlsHostCert = mkOption {
        type = types.str;
        description = "The path to certificate authority cert";
      };
      snapshotPrefix = mkOption {
        type = types.str;
        description = "A prefix to amend to zfs snapshots.";
        default = "zrepl_";
      };
      snapshotInterval = mkOption {
        type = types.str;
        description = "How often to take snapshots.";
        default = "10m";
      };
      snapshotsToKeep = mkOption {
        type = types.str;
        description = "How many snapshots to keep locally.";
        default = "4m";
      };
      fileSystems = mkOption {
        description = "A map/attr of file systems to sync.";
        default = { };
      };
      tlsCaBind = mkOption {
        type = types.nullOr types.str;
        description = "Given a path copy to /etc/zrepl/tls/ca.crt and set in config.";
        default = null;
      };
      tlsHostCertBind = mkOption {
        type = types.nullOr types.str;
        description = "Given a path copy to /etc/zrepl/tls/host.crt and set in config.";
        default = null;
      };
    };
  };
  jobConfigs = map
    (jobConfig: {
      name = "${jobConfig.name}";
      type = "push";
      connect = {
        type = "tls";
        address = "${jobConfig.destination}:${builtins.toString jobConfig.port}";
        ca = if jobConfig.tlsCaBind == null then "${jobConfig.tlsCa}" else "/etc/zrepl/tls/${jobConfig.name}_ca.crt";
        cert = if jobConfig.tlsHostCertBind == null then "${jobConfig.tlsHostCert}" else "/etc/zrepl/tls/${jobConfig.name}_host.crt";
        key = "${jobConfig.tlsHostKey}";
        server_cn = "${jobConfig.destination}";
      };
      filesystems = jobConfig.fileSystems;
      snapshotting = {
        type = "periodic";
        prefix = "${jobConfig.snapshotPrefix}";
        interval = "${jobConfig.snapshotInterval}";
      };
      pruning = {
        keep_sender = [
          { type = "not_replicated"; }
          { type = "last_n"; count = 4; }
        ];
        keep_receiver = [
          {
            type = "grid";
            grid = "1x1h(keep=all) | 24x1h | 30x1d | 6x30d";
            regex = "^${jobConfig.snapshotPrefix}";
          }
        ];
      };
    })
    config.personalConfig.linux.zrepl.jobs;
  caBinds = map
    (jobConfig: {

      name = "zrepl/tls/${jobConfig.name}_ca.crt";
      value = {
        text = jobConfig.tlsCaBind;
      };
    })
    (builtins.filter
      (
        jobConfig: jobConfig.tlsCaBind != null
      )
      config.personalConfig.linux.zrepl.jobs);
  hostCertBinds = map
    (jobConfig: {
      name = "zrepl/tls/${jobConfig.name}_host.crt";
      value = {
        text = jobConfig.tlsHostCertBind;
      };
    })
    (builtins.filter
      (
        jobConfig: jobConfig.tlsHostCertBind != null
      )
      config.personalConfig.linux.zrepl.jobs);
  certBinds = listToAttrs (
    (lib.lists.flatten [ hostCertBinds caBinds ])
  );
in
{
  options.personalConfig.linux.zrepl = {
    enable = mkOption {
      type = types.bool;
      description = "Whether to enable zrepl";
      default = false;
    };
    jobs = mkOption {
      default = [ ];
      type = types.listOf (types.submodule zreplJobOptions);
      description = "A set of jobs to run.";
    };
  };
  config = mkIf config.personalConfig.linux.zrepl.enable {
    services.zrepl = {
      enable = true;
      settings = {
        global = {
          logging = [
            {
              type = "stdout";
              level = "debug";
              format = "human";
            }
          ];
        };
        jobs = jobConfigs;
      };
    };
    systemd.services.zrepl = {
      serviceConfig = {
        ExecStartPre = lib.concatStringsSep " && " [
          "${pkgs.zrepl}/bin/zrepl --config /etc/zrepl/zrepl.yml configcheck"
          "mkdir  /var/run/zrep"
          "chmod 750 /var/run/zrepl"
        ];
      };
      after = [ "zfs.target" "network.target" ];
    };
    environment.etc = certBinds;
  };
}

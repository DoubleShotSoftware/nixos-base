{ config, lib, options, pkgs, ... }:
with lib;
with builtins;
let
  containerConfig = config.personalConfig.linux.container;
  dockerDaemonSettings = {
    bip = containerConfig.docker.broadcastIp;
    ipv6 = false;
  };
  containerEnabled = config.personalConfig.linux.container.enable;
  isDocker = config.personalConfig.linux.container.backend == "docker" || config.personalConfig.linux.container.backend == "docker-nvidia";
in
{
  options.personalConfig.linux.container = {
    enable = mkOption {
      type = types.bool;
      description = "Enable container support";
      default = false;
    };
    backend = mkOption {
      type = types.enum [ "podman" "docker" "docker-nvidia" ];
      description = lib.mdDoc "The underlying Docker implementation to use.";
      default = "docker";
    };
    docker = {
      onBoot = mkOption {
        type = types.bool;
        description = lib.mdDoc "Enable on boot.";
        default = true;
      };
      rootless = mkOption {
        type = types.bool;
        description = "Enable rootless mode";
        default = true;
      };
      broadcastIp = mkOption {
        type = types.str;
        description =
          lib.mdDoc "The broadcast ip for the base docker network interface.";
        default = "172.26.0.1/16";
      };
      storageDriver = mkOption {
        type = types.nullOr (types.enum [
          "aufs"
          "btrfs"
          "devicemapper"
          "overlay"
          "overlay2"
          "zfs"
        ]);
        default = null;
        description = lib.mdDoc ''
          This option determines which Docker storage driver to use. By default
          it let's docker automatically choose preferred storage driver.
        '';
      };
      cAdvisor = mkOption {
        default = false;
        type = types.bool;
        description = "Enable the cadvisor scraper monitoring.";
      };
    };
  };
  config = lib.mkMerge [
    (lib.mkIf
      (containerEnabled && isDocker)
      {
        virtualisation = {
          oci-containers.backend = "docker";
          docker = {
            enable = true;
            enableOnBoot = containerConfig.docker.onBoot;
            rootless = {
              enable = false;
            };
            daemon.settings = dockerDaemonSettings;
            autoPrune = {
              enable = true;
            };
          };
        };
        environment.systemPackages = [ pkgs.docker-compose pkgs.docker-buildx ];
      })
    (lib.mkIf (containerEnabled && isDocker && config.personalConfig.linux.container.docker.storageDriver != null) {
      virtualisation.docker.storageDriver = config.personalConfig.linux.container.docker.storageDriver;
    })
    #    (lib.mkIf config.personalConfig.linux.container.backend == "docker-nvidia"
    #      (
    #        trace "Enabling Docker nvidia"
    #          {
    #            virtualisation.docker = {
    #              enableNvidia = true;
    #              daemon.settings = {
    #                bip = containerConfig.docker.broadcastIp;
    #                ipv6 = false;
    #                runtimes = {
    #                  nvidia = {
    #                    path = "${pkgs.nvidia-docker}/bin/nvidia-container-runtime";
    #                  };
    #                };
    #              };
    #            };
    #            environment.systemPackages = with pkgs; [
    #              nvidia-docker
    #              unstable.nvidia-container-toolkit
    #              unstable.nvidia-container-runtime
    #            ];
    #          }
    #      ))
  ];
}

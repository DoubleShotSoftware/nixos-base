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
  isDocker = config.personalConfig.linux.container.backend == "docker"
    || config.personalConfig.linux.container.backend == "docker-nvidia";
  isPodman = config.personalConfig.linux.container.backend == "podman";
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
    podman = {
      dockerCompat = mkOption {
        type = types.bool;
        description =
          "Whether to have podman mimic docker with a compatibility layer and tools";
        default = false;
      };
      storageDriver = mkOption {
        type =
          types.enum [ "overlay" "vfs" "devmapper" "aufs" "btrfs" "zfs" ];
        default = "overlay";
        description = "The podman storage driver to user.";
      };
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
        default = false;
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
    (lib.mkIf (containerEnabled && isDocker) {
      virtualisation = {
        oci-containers.backend = "docker";
        docker = {
          enable = true;
          enableOnBoot = containerConfig.docker.onBoot;
          daemon.settings = dockerDaemonSettings;
          autoPrune = { enable = true; };
        };
      };
      environment.systemPackages = [ pkgs.docker-compose pkgs.docker-buildx ];
    })
    (lib.mkIf
      (containerEnabled && isDocker
        && config.personalConfig.linux.container.docker.storageDriver != null)
      {
        virtualisation.docker.storageDriver =
          config.personalConfig.linux.container.docker.storageDriver;
      })
    (lib.mkIf (containerEnabled && isPodman) {
      virtualisation = {
        containers = {
          enable = true;
          storage.settings = {
            storage = {
              driver = containerConfig.podman.storageDriver;
              runroot = "/run/containers/storage";
              graphroot = "/var/lib/containers/storage";
            };
          };
        };
        podman = {
          enable = true;
          autoPrune.enable = true;
        };
      };
      environment.systemPackages = with pkgs; [ podman-tui ];
    })
    (lib.mkIf
      (containerEnabled && isPodman && containerConfig.podman.dockerCompat)
      {
        environment.systemPackages = with pkgs;
          [ podman-compose ];
        virtualisation = {
          podman = {
            dockerSocket.enable = true;
            dockerCompat = true;

          };
        };
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

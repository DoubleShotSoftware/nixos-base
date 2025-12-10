# Persistent volume configuration for factory VMs
# Handles LUKS-encrypted Btrfs volume with subvolumes
{ config, lib, pkgs, ... }:
{
  boot.initrd.luks.devices = {
    cryptdata = {
      # Use the label of the encrypted device
      device = "/dev/disk/by-label/enc_cryptdata";
      preLVM = true;
      allowDiscards = false;
    };
  };
  
  fileSystems = {
    # Mount @home subvolume to /persist
    "/persist" = {
      device = "/dev/mapper/cryptdata";
      fsType = "btrfs";
      options = [ "subvol=@home" "compress=zstd" "noatime" ];
      neededForBoot = false;
    };
    
    # Note: We don't directly mount @etc, @var_lib etc to system directories
    # The persist-mount service will copy files from these subvolumes
    # This avoids conflicts with existing system directories
  };
  
  # Ensure Btrfs tools are available
  boot.initrd.supportedFilesystems = [ "btrfs" ];
  
  # Enable Btrfs scrubbing for data integrity
  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    fileSystems = [ "/persist" ];
  };
}
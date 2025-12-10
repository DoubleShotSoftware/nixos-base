# Persistent Volume Mount Service
# Handles mounting all subvolumes after LUKS unlock
{ config, lib, pkgs, ... }:
with lib;
{
  config = {
    # Service to mount persistent subvolumes
    systemd.services.persist-mount = {
      description = "Mount persistent volume subvolumes";
      after = [ "systemd-cryptsetup@cryptdata.service" ];
      wants = [ "systemd-cryptsetup@cryptdata.service" ];
      before = [ "gitops-token-setup.service" "vm-cutover.service" ];
      wantedBy = [ "multi-user.target" ];
      
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        StandardOutput = "journal+console";
        StandardError = "journal+console";
      };
      
      path = with pkgs; [
        util-linux  # for mount, umount, mountpoint
        coreutils   # for basic commands
        btrfs-progs # for btrfs operations
      ];
      
      script = ''
        set -e
        
        echo "Checking for encrypted volume..."
        
        # Wait for cryptdata device
        RETRIES=10
        while [ ! -e /dev/mapper/cryptdata ] && [ $RETRIES -gt 0 ]; do
          echo "Waiting for /dev/mapper/cryptdata... ($RETRIES retries left)"
          sleep 2
          RETRIES=$((RETRIES - 1))
        done
        
        if [ ! -e /dev/mapper/cryptdata ]; then
          echo "ERROR: Encrypted volume not found at /dev/mapper/cryptdata"
          echo "Please unlock the volume first with: cryptsetup luksOpen /dev/vdb cryptdata"
          exit 1
        fi
        
        echo "Encrypted volume found, processing subvolumes..."
        
        # /persist should be mounted by systemd with @home subvolume
        if [ -d "/persist" ]; then
          echo "✓ /persist is mounted"
        else
          echo "ERROR: /persist is not mounted"
          echo "Check systemd mount units"
          exit 1
        fi
        
        # Mount root of btrfs to access other subvolumes
        echo "Mounting btrfs root to access subvolumes..."
        BTRFS_ROOT=$(mktemp -d)
        if ! mount -o compress=zstd /dev/mapper/cryptdata "$BTRFS_ROOT"; then
          echo "ERROR: Failed to mount btrfs root"
          exit 1
        fi
        
        # Copy files from @etc subvolume
        if [ -d "$BTRFS_ROOT/@etc" ]; then
          echo "Copying files from @etc subvolume..."
          
          # Copy gitops directory
          if [ -d "$BTRFS_ROOT/@etc/gitops" ]; then
            echo "  - Copying /etc/gitops"
            cp -a "$BTRFS_ROOT/@etc/gitops" /etc/
          fi
          
          # Copy SSH host keys
          if [ -d "$BTRFS_ROOT/@etc/ssh" ]; then
            echo "  - Copying SSH host keys"
            cp -a "$BTRFS_ROOT/@etc/ssh/ssh_host_"* /etc/ssh/ 2>/dev/null || true
          fi
        fi
        
        # Copy files from @var_lib subvolume
        if [ -d "$BTRFS_ROOT/@var_lib" ]; then
          echo "Copying files from @var_lib subvolume..."
          
          # Copy sops directory
          if [ -d "$BTRFS_ROOT/@var_lib/sops" ]; then
            echo "  - Copying /var/lib/sops"
            mkdir -p /var/lib/sops
            cp -a "$BTRFS_ROOT/@var_lib/sops/"* /var/lib/sops/ 2>/dev/null || true
          fi
        fi
        
        # Unmount btrfs root
        umount "$BTRFS_ROOT"
        rmdir "$BTRFS_ROOT"
        
        echo "All persistent subvolumes mounted successfully"
        
        # Verify critical files
        echo "Verifying critical files..."
        if [ -f /etc/gitops/vm-config.json ]; then
          echo "✓ VM configuration found"
        else
          echo "⚠ VM configuration not found at /etc/gitops/vm-config.json"
        fi
        
        if [ -f /etc/gitops/tokens.json ]; then
          echo "✓ GitOps tokens found"
        else
          echo "⚠ GitOps tokens not found at /etc/gitops/tokens.json"
        fi
        
        if [ -f /var/lib/sops/age.key ]; then
          echo "✓ Age key found"
        else
          echo "⚠ Age key not found at /var/lib/sops/age.key"
        fi
      '';
    };
    
    # Update gitops-token-setup to depend on persist-mount
    systemd.services.gitops-token-setup = {
      after = mkForce [ "persist-mount.service" ];
      requires = mkForce [ "persist-mount.service" ];
    };
    
    # Update vm-cutover to depend on persist-mount
    systemd.services.vm-cutover = {
      after = mkForce [ "gitops-token-setup.service" "persist-mount.service" ];
      requires = mkForce [ "gitops-token-setup.service" "persist-mount.service" ];
    };
  };
}
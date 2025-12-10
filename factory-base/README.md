# Factory Base Images for VMs

This module provides minimal factory base images for VMs following the ADR-018 vision with a pragmatic MVP approach.

## Overview

- **Minimal base image** (~500MB) that VMs build upon
- **Multiple output formats** for different hypervisors
- **DHCP networking** for simple bootstrap
- **Overlay store** to separate base from VM-specific packages (Nix 2.22+)
- **Manual cutover process** to apply VM-specific configuration

## Structure

```
factory-base/
├── base.nix               # Main factory image configuration
├── modules/
│   ├── vm-config.nix      # VM configuration seeding
│   ├── overlay-store.nix  # Overlay store setup (Nix 2.22+)
│   └── persistent.nix     # LUKS-encrypted persistent volume
├── test/
│   └── example-vm.nix     # Example test VM
└── scripts/
    ├── vm-cutover.sh      # Manual cutover script
    └── create-data-disk.sh # Create encrypted data disk
```

## Building Images

### Available Formats

From the repository root:

```bash
# QEMU/KVM formats
nix build .#factory-base          # QCOW2 with UEFI (default)
nix build .#factory-qcow          # QCOW2 with BIOS
nix build .#factory-raw           # Raw disk image with UEFI

# Hypervisor-specific formats  
nix build .#factory-hyperv        # Hyper-V VHDX
nix build .#factory-vmware        # VMware VMDK
nix build .#factory-virtualbox    # VirtualBox VDI

# Cloud provider formats
nix build .#factory-openstack     # OpenStack QCOW2
nix build .#factory-proxmox       # Proxmox VMA

# Test VM
nix build .#factory-test          # Test VM with nginx

# Output location varies by format:
# result/nixos.qcow2, result/nixos.vhdx, result/nixos.vmdk, etc.
```

### Architecture Support

Each architecture builds its own native images:
- x86_64-linux: All formats supported
- aarch64-linux: Most formats supported (check nixos-generators docs)

The flake automatically builds for the current system architecture.

## Creating Persistent Data Disk

```bash
# Create a 20GB encrypted data disk
sudo factory-base/scripts/create-data-disk.sh 20 vm-data.img

# You'll be prompted for LUKS password
# Save the generated age public key for sops configuration
```

## VM Configuration Methods

### 1. Embedded (Default for MVP)

Configuration is baked into the image during build:

```nix
vm.config = {
  enable = true;
  method = "embedded";
  hostname = "web-01";
  repo = "git+ssh://gitea.local/infrastructure/vm-configs";
  branch = "main";
};
```

### 2. Kernel Command Line

Pass via libvirt XML:
```xml
<cmdline>vm.hostname=web-01 vm.repo=git+ssh://...</cmdline>
```

### 3. SystemD Credentials

Most secure but requires more setup.

## Deployment Process

### 1. Create VM with Factory Image

```bash
# Example with libvirt
virt-install \
  --name web-01 \
  --memory 2048 \
  --disk path=factory-base.qcow2,bus=virtio \
  --disk path=data.img,bus=virtio \
  --network network=default \
  --graphics none \
  --console pty,target_type=serial
```

### 2. Initial Boot

1. Connect to serial console
2. Enter LUKS password when prompted
3. VM boots with DHCP networking

### 3. Manual Cutover

Run the cutover script to apply VM-specific configuration:

```bash
sudo vm-cutover
```

This will:
- Read VM configuration from `/etc/vm-config.json`
- Clone the specified repository to `/persist/nixos`
- Rebuild the system with the VM's configuration

## Networking

The factory image uses DHCP by default. This works with:
- Libvirt default network (virbr0)
- VMware NAT
- Hyper-V default switch
- Most cloud providers

After cutover, the VM's real configuration can set:
- Static IPs
- WireGuard tunnels
- Custom DNS
- VLANs
- etc.

## Overlay Store

The overlay store feature (requires Nix 2.22+) allows:
- Factory `/nix` as read-only lower layer
- `/persist/nix` as read-write upper layer
- Automatic garbage collection
- Significant space savings

## Future Enhancements

### Near Term
- GitOps automation (sync-config service)
- Binary cache for shared packages
- Automated testing of factory images

### Potential Features
- Static network config via kernel cmdline (`vm.network_static`)
- Pre-staged WireGuard tools
- TPM2/Clevis for automatic LUKS unlock
- Zero-touch provisioning

## Technical Notes

### What nixos-generators Provides

The nixos-generators formats handle:
- Boot loader configuration (GRUB/systemd-boot)
- Serial console setup (architecture-specific)
- Kernel modules for virtualization
- Disk partitioning and filesystem layout
- Image format conversion

Our factory-base only adds:
- LUKS-encrypted persistent volume support
- VM configuration seeding
- Overlay store setup
- Essential packages
- DHCP networking

### Minimal by Design

The factory image is intentionally minimal. After cutover, the VM's real configuration (from git) handles:
- Service configuration
- User accounts
- Network topology (WireGuard, VLANs, etc.)
- Application deployment
- Security policies

## See Also

- `/in-progress-adr.md` - Full MVP implementation plan
- `adr_018_factory_image_fleet.md` - Original vision
- [nixos-generators documentation](https://github.com/nix-community/nixos-generators)
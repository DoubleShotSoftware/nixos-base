# Factory Base Working Session Notes

## Session Date: 2025-07-09

### Overview
This session focused on implementing GitOps authentication for factory VMs, allowing them to clone private git repositories and use private Nix flake inputs.

## Major Components Implemented

### 1. GitOps Authentication System

#### Access Token Storage
- Tokens stored as JSON on LUKS-encrypted persistent disk
- Path: `/etc/gitops/tokens.json` (via `@etc` subvolume mount)
- Format:
```json
{
  "github.com": "ghp_xxxxxxxxxxxx",
  "gitlab.com": "glpat_xxxxxxxxxxxx",
  "git.home.lan.animus.design": "token_xxxxxxxxxxxx"
}
```

#### Token Conversion Service
- **Module**: `factory-base/modules/gitops-tokens.nix`
- **Service**: `gitops-token-setup.service`
- Converts JSON tokens to:
  1. Nix access tokens: `/etc/nix/access-tokens.conf`
  2. Git credentials: `/var/lib/nix-gitops/.git-credentials`

#### GitOps User
- Created `nix-gitops` system user
- Owns git credentials
- Has sudo access for `nixos-rebuild`
- VM cutover runs as this user

### 2. Disk Creation Script Improvements

#### Script: `factory-base/scripts/create-data-disk.sh`

**Issues Fixed:**
- Added comprehensive input validation
- Fixed cleanup race conditions
- Added progress indicators [1/7] style
- Fixed qcow2 conversion (was happening after cleanup)
- Better error handling with recovery instructions
- Handles relative paths for tokens file
- Added `jq` to nix-shell dependencies

**New Options:**
- `--tokens-json PATH` - Provide JSON file with access tokens
- `--edit-tokens` - Interactive token editor

**Key Improvements:**
- Validates image name (catches .qcow2 extension error)
- Checks for existing LUKS/loop devices
- SUCCESS flag prevents cleanup on successful completion
- Better unmount with sync and retry

### 3. Factory Constants System

#### Module: `factory-base/constants.nix`
Configurable paths to fix subvolume mount confusion:
```nix
factory.constants = {
  tokensPath = "/etc/gitops/tokens.json";
  nixAccessTokensPath = "/etc/nix/access-tokens.conf";
  gitCredentialsPath = "/var/lib/nix-gitops/.git-credentials";
}
```

### 4. VM Configuration Updates

#### Base Configuration (`factory-base/base.nix`)
- Added nix-gitops user with wheel group
- Included `!include` directive for access tokens
- Imported gitops-tokens module
- Added factory constants

#### VM Cutover Script (`factory-base/scripts/vm-cutover.sh`)
- Simplified to use automatic git credentials
- Checks gitops-token-setup service
- Runs as nix-gitops user via sudo wrapper

## Files Created/Modified

### New Files
1. `factory-base/modules/gitops-tokens.nix` - Token conversion service
2. `factory-base/constants.nix` - Configurable paths
3. `factory-base/README-auth.md` - Authentication documentation
4. `factory-base/test/example-tokens.json` - Example tokens file
5. `factory-base/TODO-cicd-disk-creation.md` - Future CI/CD ideas

### Modified Files
1. `factory-base/base.nix` - Added nix-gitops user, constants, token inclusion
2. `factory-base/scripts/create-data-disk.sh` - Major robustness improvements
3. `factory-base/scripts/vm-cutover.sh` - Simplified for automatic auth
4. `factory-base/modules/vm-config.nix` - Added gitCredentialsFile option

## Authentication Flow

1. **Disk Creation**: Tokens stored in `@etc/gitops/tokens.json` on encrypted disk
2. **VM Boot**: `@etc` subvolume mounts to `/etc`
3. **Service Start**: `gitops-token-setup` converts tokens to both formats
4. **Cutover**: `vm-cutover` runs as nix-gitops, uses credentials automatically
5. **Result**: Both `git clone` and `nix flake` operations authenticate transparently

## Testing Results

### Successful Test
- Created disk with tokens for github.com and git.home.lan.animus.design
- Factory VM booted and mounted encrypted disk
- gitops-token-setup service ran successfully
- Tokens available at correct paths

### Issues Encountered
1. **Path Confusion**: Service looked in `/persist/etc/` instead of `/etc/`
   - Fixed with constants module
2. **Script Fragility**: Multiple edge cases in disk creation
   - Fixed with validation and better cleanup
3. **Missing jq**: Script failed due to missing dependency
   - Added to nix-shell

## Usage Examples

### Create Disk with Tokens
```bash
# Create tokens file
cat > tokens.json <<EOF
{
  "github.com": "ghp_YOUR_TOKEN",
  "git.home.lan.animus.design": "YOUR_GITEA_TOKEN"
}
EOF

# Create 20GB encrypted disk
sudo factory-base/scripts/create-data-disk.sh 20 vm-data.img --tokens-json tokens.json
```

### Deploy VM
```bash
# Create VM with both disks
sudo virt-install \
  --name factory-test \
  --memory 2048 \
  --disk path=factory-test.qcow2,bus=virtio \
  --disk path=vm-data.img.qcow2,bus=virtio \
  --network network=default \
  --graphics none \
  --console pty,target_type=serial \
  --boot uefi \
  --osinfo nixos-24.05 \
  --import
```

## Key Learnings

1. **Subvolume Mounts**: `@etc` mounted to `/etc` means files appear there, not under `/persist`
2. **Bash Complexity**: Script reaching limits, consider Python for future
3. **Nix Access Tokens**: Same tokens work for both git and nix operations
4. **Error Recovery**: Clear error messages with fix instructions are essential

## Next Steps

1. Test with actual private repository
2. Consider CI/CD automation (see TODO-cicd-disk-creation.md)
3. Add more robust error handling in gitops-token-setup
4. Document VM-specific configuration examples

## Security Notes

- Tokens only on encrypted disk
- 600 permissions on credential files
- nix-gitops user has minimal privileges
- `!include` directive ignores missing files (no boot failures)
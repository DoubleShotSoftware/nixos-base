# GitOps Authentication for Factory VMs

This document explains how authentication works for private git repositories in the factory VM system.

## Overview

The factory VM system uses access tokens for both:
1. **Nix flake inputs** - Fetching private dependencies
2. **Git operations** - Cloning the VM configuration repository

## Token Storage

Tokens are stored in JSON format on the encrypted persistent disk at:
```
/persist/etc/gitops/tokens.json
```

Format:
```json
{
  "github.com": "ghp_xxxxxxxxxxxx",
  "gitlab.com": "glpat_xxxxxxxxxxxx", 
  "gitea.local": "token_xxxxxxxxxxxx"
}
```

## Creating a Persistent Disk with Tokens

### Option 1: Provide a JSON file
```bash
# Create tokens file
cat > tokens.json <<EOF
{
  "github.com": "ghp_yourtokenhere",
  "gitlab.com": "glpat_yourtokenhere"
}
EOF

# Create disk with tokens
sudo factory-base/scripts/create-data-disk.sh 20 vm-data.img --tokens-json tokens.json
```

### Option 2: Interactive editor
```bash
# Launch editor to create tokens
sudo factory-base/scripts/create-data-disk.sh 20 vm-data.img --edit-tokens
```

## How It Works

1. **Disk Creation**: Tokens are stored in `/persist/etc/gitops/tokens.json` on the encrypted disk

2. **Boot Time**: The `gitops-token-setup` systemd service:
   - Converts JSON tokens to Nix format: `/persist/etc/nix/access-tokens.conf`
   - Creates git credentials: `/var/lib/nix-gitops/.git-credentials`

3. **Nix Usage**: Nix automatically uses tokens via:
   ```nix
   nix.extraOptions = ''
     !include /persist/etc/nix/access-tokens.conf
   '';
   ```

4. **Git Usage**: The `nix-gitops` user has credentials configured:
   ```
   https://token@github.com
   https://oauth2:token@gitlab.com
   ```

## Token Formats by Provider

### GitHub
- Personal Access Token: `ghp_xxxxxxxxxxxx`
- Format in git credentials: `https://TOKEN@github.com`

### GitLab
- Personal Access Token: `glpat_xxxxxxxxxxxx`
- Format in git credentials: `https://oauth2:TOKEN@gitlab.com`

### Gitea/Self-hosted
- Access Token: `token_xxxxxxxxxxxx`
- Format in git credentials: `https://TOKEN@gitea.local`

## Security Notes

1. Tokens are stored on LUKS-encrypted volumes
2. Token files have 600 permissions (root/nix-gitops only)
3. The `!` prefix in nix.conf prevents errors if file doesn't exist
4. Git credentials are only accessible to the `nix-gitops` user

## Troubleshooting

Check token setup:
```bash
# View systemd service status
systemctl status gitops-token-setup

# Check if nix tokens are configured
cat /persist/etc/nix/access-tokens.conf

# Check git credentials (as root)
sudo -u nix-gitops cat /var/lib/nix-gitops/.git-credentials
```

## VM Cutover Process

The `vm-cutover` command:
1. Runs as `nix-gitops` user automatically
2. Uses git credentials from `~/.git-credentials`
3. Clones repository with automatic authentication
4. Runs `nixos-rebuild` with access to private flake inputs
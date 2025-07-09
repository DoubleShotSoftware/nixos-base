# TODO: CI/CD Disk Creation

## Future Enhancement: Automated Disk Building

The current `create-data-disk.sh` script requires interactive password entry. For CI/CD workflows, we could:

### 1. Non-Interactive LUKS
```bash
# Use key file instead of interactive password
cryptsetup luksFormat --key-file /tmp/keyfile --batch-mode /dev/loop0
```

### 2. Config-Driven Approach
```json
{
  "name": "web-01-data",
  "size_gb": 20,
  "tokens": {
    "github.com": "$GITHUB_TOKEN",
    "git.home.lan": "$GITEA_TOKEN"
  }
}
```

### 3. Nix Derivation
Build disks as Nix derivations for reproducibility and caching.

### 4. Automated Upload
Upload built images to S3/Minio for distribution.

---
**Note**: Deferred for now. Focus on making interactive script robust first.
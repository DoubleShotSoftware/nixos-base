# NixOS Base - personalConfig Modules

Shared NixOS and Home Manager modules providing standardized configuration options across all hosts.

## Overview

- **Flake URL**: `git+ssh://git@gitea.home.lan.animus.design/animusnull/nixos-base.git`
- **Branch**: `25_11` (follows NixOS release cycle)
- **Purpose**: Centralized, reusable NixOS configuration components

## Repository Structure

```
nixos-base/
├── flake.nix              # Flake definition with all exports
├── models/                # Option definitions (personalConfig schema)
│   ├── default.nix        # Main options aggregator
│   ├── user.nix           # User configuration options
│   ├── system.nix         # System-wide options
│   ├── networking.nix     # Network configuration
│   ├── libvirt.nix        # Linux-specific (ZFS, containers, guests)
│   └── languageSettings.nix
├── components/            # Implementation modules
│   ├── general/           # Cross-platform components
│   ├── linux/             # Linux-specific implementations
│   ├── macos/             # macOS implementations
│   └── languages/         # Development language toolchains
├── home-manager/          # Home Manager modules
├── packages/              # Custom packages
│   └── vimPlugins/        # Custom Neovim plugins
├── nixvim/                # Nixvim IDE configuration
└── nixcats/               # NixCats Neovim alternative
```

## Flake Outputs

### nixosModules

| Module | Description |
|--------|-------------|
| `Common` | General configuration + overlays |
| `Linux` | ZFS, containers, guests, NIC renaming |
| `MacOs` | macOS-specific configuration |
| `HomeManager` | Home Manager integration |
| `Languages` | Development language toolchains |

### homeManagerModules

- `default` - Standard home-manager configuration
- `languages` - Per-language home-manager setup

### packages

- `nixvim` / `nixvim-lite` - Neovim IDE distributions
- `nixcats` / `nixcats-full` / `nixcats-dev` - NixCats Neovim variants

### overlays

- `default` - Adds `unstable`, `dotnetSDK`, `nvim-ide`, custom packages

## personalConfig Option Structure

The `personalConfig` option namespace provides these configuration groups:

### system

```nix
personalConfig.system = {
  nixStateVersion = "25.11";           # NixOS state version
  remoteDevSupport = true;             # Enable remote dev packages
  remoteDevSupportExtr = [ ... ];      # Extra remote dev packages
};
```

### linux

```nix
personalConfig.linux = {
  zfs = {
    enable = true;
    immutable = true;                  # Immutable root filesystem
  };
  guest = {
    enable = true;
    graphical = false;                 # Headless VM
  };
  container = {
    enable = true;
    backend = "docker";                # or "podman"
    docker = {
      rootless = false;
      onBoot = true;
      networkAccessible = true;
      storageDriver = "overlay2";
      broadcastIp = "10.16.0.1/16";
    };
  };
  renameNics = [
    { name = "lan"; mac = "xx:xx:xx:xx:xx:xx"; }
  ];
};
```

### users

```nix
personalConfig.users.<username> = {
  admin = true;                        # Sudo access
  userType = "normal";                 # User type
  languages = ["typescript" "python"]; # Dev toolchains
  nvim = true;                         # Neovim IDE
  nixBuilder = true;                   # Nix build permissions
  extraGroups = ["docker"];
  keys.ssh = [ ./path/to/key.pub ];
  zsh.enable = true;
  git = {
    enable = true;
    userName = "...";
    userEmail = "...";
    dirConfig.<name> = {               # Per-directory git config
      path = "/path/to/repo";
      userName = "...";
      userEmail = "...";
    };
  };
};
```

### networking

```nix
personalConfig.networking = {
  # Network-related options
};
```

### cockpit

```nix
personalConfig.cockpit = {
  # Cockpit web console options
};
```

### libvirt / firecracker

```nix
personalConfig.libvirt = { ... };
personalConfig.firecracker = { ... };
```

### dnsmasq

```nix
personalConfig.linux.dnsmasq = {
  enable = true;
  dnsServers = [ "1.1.1.1" "8.8.8.8" ];
  domain = "zipline.colo-miami.lan.animus.design";  # expand-hosts appends this
  interfaces = [{
    interface = "lan";
    dhcp = true;
    listenOn = "10.10.202.1";
    lowerRange = "10.10.202.100";
    upperRange = "10.10.202.200";
    leaseTime = 12;  # hours
  }];
  ethers = [{
    mac = "52:54:00:a4:d5:29";
    hostname = "win";
    ip = "10.10.202.10";
  }];
  domainOverrides = [{
    domain = "internal.company.com";
    includeSubdomains = true;
    target = [ "192.168.1.53" ];
  }];
};
```

**Key behaviors:**
- Creates `/etc/ethers` for MAC→hostname mapping
- Always generates `/etc/hosts` from ethers (hostname→IP) using `lib.mkAfter` for merging
- dnsmasq `read-ethers` + `/etc/hosts` enables static DHCP assignments
- `expand-hosts` + `domain` expands short hostnames to FQDNs in DNS responses

## Usage in Host Configs

In your host flake (e.g., `~/.nixos`):

```nix
# flake.nix inputs
personalConfig = {
  url = "git+ssh://git@gitea.home.lan.animus.design/animusnull/nixos-base.git?ref=25_11";
  inputs.nixpkgs.follows = "nixpkgs";
};

# nixos-configurations.nix
defaultModules = system: [
  personalConfig.nixosModules.Common
  personalConfig.nixosModules.Linux
  personalConfig.nixosModules.Languages
  personalConfig.nixosModules.HomeManager
  # ...
];
```

Then in host configs:

```nix
# hosts/myhost/personal-config.nix
{
  personalConfig = {
    system.nixStateVersion = "25.11";
    linux.zfs.enable = true;
    users.myuser = {
      admin = true;
      nvim = true;
    };
  };
}
```

## Development

```bash
# Enter development shell
nix develop

# Build a package
nix build .#nixvim

# Check flake
nix flake check

# Update inputs
nix flake update
```

## Related

- `~/.nixos` - Main host configuration repository that consumes this flake
- `work-config` - Work-specific modules (similar structure)

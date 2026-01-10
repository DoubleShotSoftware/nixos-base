# nixcats - Neovim Configuration

A [nixCats](https://github.com/BirdeeHub/nixCats-nvim)-based Neovim configuration with Lua-first philosophy and Nix reproducibility.

## Quick Start

```bash
# Minimal (nix language only)
nix run .#nixcats

# Full IDE (all languages)
nix run .#nixcats-full

# Dev mode (live Lua reload for config development)
nix run .#nixcats-dev
```

## Philosophy

**Lua-first**: Configuration lives in standard Lua files, making it portable and familiar to any Neovim user.

**Nix for dependencies**: Plugins, LSPs, and tools are managed by Nix, ensuring reproducibility without polluting your system.

**Category-based loading**: Enable languages via a simple list - only the requested language tooling is included.

## Architecture

```
nixcats/
├── default.nix          # Builder function (mkNixCats)
├── languages/           # Language-specific Nix configs
│   ├── default.nix      # Language module loader & merging
│   ├── nix.nix          # Nix: nixd, alejandra
│   ├── dotnet.nix       # .NET: roslyn-ls, easy-dotnet, netcoredbg
│   ├── rust.nix         # Rust: rust-analyzer, rustaceanvim
│   ├── python.nix       # Python: pyright, black, ruff
│   ├── typescript.nix   # TypeScript: ts_ls, eslint, prettier
│   ├── json.nix         # JSON: jsonls, schemastore
│   └── sql.nix          # SQL: sqls, pgformatter
└── lua/                 # Neovim Lua configuration
    ├── init.lua         # Entry point
    └── lua/
        ├── core/        # options.lua, keymaps.lua
        └── plugins/     # Plugin configs (lsp.lua, telescope.lua, etc.)
```

## How It Works

### 1. Flake Overlay (Single Source of Truth)

The `flake.nix` overlay defines shared packages used by both nixvim and nixcats:

```nix
overlays.default = final: prev: {
  dotnetSDK = ...;              # Combined .NET SDKs
  customVimPlugins = ...;       # Custom vim plugins (roslyn-nvim, etc.)
  easy-dotnet-tool = ...;       # CLI tools
};
```

### 2. mkNixCats Builder

Receives pre-configured `pkgs` (with overlay) and builds Neovim:

```nix
nixcatsLib.mkNixCats {
  inherit system stablePkgs;
  pkgs = unstablePkgs;          # Has overlay applied
  languages = [ "nix" "dotnet" "rust" ];
  wrapRc = true;                # Hermetic build
}
```

### 3. Language Modules

Each `languages/{lang}.nix` returns:

```nix
{
  lspsAndRuntimeDeps = [ ... ];   # LSPs, formatters, tools
  startupPlugins = [ ... ];       # Always-loaded plugins
  optionalPlugins = [ ... ];      # Lazy-loaded plugins
  environmentVariables = { };     # DOTNET_ROOT, etc.
  extra = { };                    # Passed to Lua via nixCats.extra
}
```

### 4. Category System

Languages list becomes nixCats categories:

```nix
languages = [ "dotnet" "rust" ]
# Creates: nixCats.cats["languages.dotnet"] = true
#          nixCats.cats["languages.rust"] = true
```

In Lua, guard language-specific config:

```lua
if not nixCats.cats["languages.dotnet"] then return end
-- dotnet-specific setup here
```

### 5. Passing Nix Paths to Lua

Use `extra` to pass Nix store paths:

```nix
# In languages/dotnet.nix
extra = {
  roslynDLLPath = "${roslyn-ls}/lib/roslyn-ls/...";
};
```

```lua
-- In lua/plugins/dotnet.lua
local roslynDLLPath = nixCats.extra.roslynDLLPath
```

## Adding a New Language

### Step 1: Create Language Module

Create `nixcats/languages/{lang}.nix`:

```nix
{ pkgs, stablePkgs, ... }:
{
  lspsAndRuntimeDeps = with pkgs; [
    your-lsp
    your-formatter
  ];

  startupPlugins = with pkgs.vimPlugins; [
    language-specific-plugin
  ];

  optionalPlugins = [ ];

  environmentVariables = { };

  extra = {
    # Optional: paths needed in Lua
  };
}
```

### Step 2: Register Language

Add to `languages/default.nix`:

```nix
availableLanguages = {
  # ... existing languages ...
  yourlang = ./yourlang.nix;
};
```

### Step 3: Add Lua Config (if needed)

Create `lua/lua/plugins/{lang}.lua`:

```lua
local nixCats = require('nixCats')

if not nixCats.cats["languages.yourlang"] then
  return
end

-- Your plugin setup here
require("your-plugin").setup({ ... })
```

Add to `lua/lua/plugins/init.lua`:

```lua
require('plugins.yourlang')
```

### Step 4: Test

```bash
nix build .#nixcats-full --no-link
nix run .#nixcats-full
```

## Key Concepts

| Concept | Description |
|---------|-------------|
| `pkgs.dotnetSDK` | Combined .NET SDK from overlay |
| `pkgs.customVimPlugins` | Custom vim plugins (roslyn-nvim) |
| `stablePkgs` | Stable nixpkgs for packages that break on unstable |
| `wrapRc = true` | Hermetic: Lua baked into derivation |
| `wrapRc = false` | Dev mode: reads from `./lua` at runtime |
| `nixCats.cats[key]` | Check if category enabled |
| `nixCats.extra[key]` | Access Nix values in Lua |

## Customization

### Via mkNixCats Parameters

```nix
nixcatsLib.mkNixCats {
  languages = [ "nix" "rust" ];     # Enable languages
  extraPlugins = [ ... ];           # Additional plugins
  extraPackages = [ ... ];          # Additional runtime deps
  extraCategories = { debug = true; };  # Enable debug plugins
  wrapRc = false;                   # Dev mode
}
```

### Available Languages

- `nix` - nixd, alejandra
- `dotnet` - roslyn-ls, easy-dotnet, netcoredbg, csharpier
- `rust` - rust-analyzer, rustaceanvim
- `python` - pyright, black, ruff, isort
- `typescript` - ts_ls, eslint, prettier
- `json` - jsonls with schemastore
- `sql` - sqls, pgformatter

## Comparison with nixvim

| Aspect | nixvim | nixcats |
|--------|--------|---------|
| Config style | Nix DSL | Native Lua |
| Plugin config | Nix options | Lua setup() calls |
| Portability | Nix-only | Lua portable anywhere |
| Learning curve | Learn nixvim DSL | Standard Neovim |
| Flexibility | Constrained by options | Full Lua freedom |

Both coexist in this repo during transition. nixvim: `nix run .#nixvim`, nixcats: `nix run .#nixcats-full`.

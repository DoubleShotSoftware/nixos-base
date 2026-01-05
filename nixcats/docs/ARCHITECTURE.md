# Architecture

This document explains how nixcats works internally.

## Overview

nixcats is built on [nixCats-nvim](https://github.com/BirdeeHub/nixCats-nvim), which provides:

1. **Nix package management** for plugins, LSPs, and tools
2. **Category system** for conditional dependency loading
3. **Lua passthrough** for accessing Nix values in Lua config

The key philosophy is **Lua-first configuration**: all Neovim config is written in standard Lua, while Nix handles dependencies.

## nixcats vs nixvim

| Aspect | nixvim | nixcats |
|--------|--------|---------|
| **Config language** | Nix DSL | Native Lua |
| **Plugin config** | Nix options | Lua `setup()` calls |
| **Portability** | Nix-only | Lua works anywhere |
| **Complexity** | Learn nixvim DSL | Standard Neovim |
| **Build model** | Always hermetic | Dev mode available |
| **Customization** | Via Nix options | Direct Lua editing |

**When to use nixcats**:
- You want standard Neovim Lua config
- You need a dev mode for rapid iteration
- You prefer editing Lua over Nix

**When to use nixvim**:
- You want everything declarative in Nix
- You prefer nix-community maintained plugin configs
- You don't mind rebuilding for every change

---

## How It Works

### 1. Flake Overlay

The `flake.nix` defines a shared overlay providing custom packages:

```nix
overlays.default = final: prev: {
  dotnetSDK = ...;           # Combined .NET SDKs
  customVimPlugins = {       # Custom vim plugins
    roslyn-nvim = ...;
    telescope-tabs = ...;
    vscode-diff = ...;
  };
  kotlin-lsp = ...;          # Custom packages
};
```

This overlay is applied to `pkgs` before passing to nixcats.

### 2. mkNixCats Builder

The `nixcats/default.nix` exports `mkNixCats`:

```nix
mkNixCats = {
  system,
  pkgs,           # Pre-configured pkgs (with overlay)
  stablePkgs,     # Stable pkgs for certain packages
  languages,      # List of languages to enable
  theme,          # Colorscheme
  wrapRc,         # Hermetic (true) or dev mode (false)
  extraPlugins,
  extraPackages,
  extraCategories,
}:
```

It builds the Neovim package using nixCats `baseBuilder`:

```nix
nixCats.utils.baseBuilder ./lua {
  inherit nixpkgs system;
} categoryDefinitions packageDefinitions "nixcats-ide"
```

### 3. Category Definitions

Categories define what goes into the build:

```nix
categoryDefinitions = { pkgs, ... }: {
  lspsAndRuntimeDeps = {
    general = [ ripgrep fd git ... ];
    "languages.nix" = [ nixd alejandra ... ];
    "languages.rust" = [ rust-analyzer ... ];
  };

  startupPlugins = {
    general = [ telescope-nvim nvim-lspconfig ... ];
    "languages.rust" = [ rustaceanvim ];
  };

  optionalPlugins = {
    debug = [ nvim-dap nvim-dap-ui ];
  };
};
```

### 4. Language Module System

Language modules in `languages/` return structured configs:

```nix
# languages/rust.nix
{
  lspsAndRuntimeDeps = [ rust-analyzer rustfmt clippy ];
  startupPlugins = [ rustaceanvim crates-nvim ];
  optionalPlugins = [ ];
  environmentVariables = { };
  extra = { };
}
```

The `languages/default.nix` merges all enabled languages:

```nix
getLanguageConfigs = { pkgs, languages, ... }:
  # For languages = ["nix", "rust"]:
  # Creates categories:
  #   "languages.nix" -> nix.nix config
  #   "languages.rust" -> rust.nix config
```

### 5. Category System

The `languages` list becomes nixCats categories:

```nix
languages = ["dotnet" "rust"]

# Becomes:
categories = {
  general = true;
  "languages.dotnet" = true;
  "languages.rust" = true;
}
```

In Lua, access via `nixCats.cats`:

```lua
local nixCats = require('nixCats')

if nixCats.cats["languages.dotnet"] then
  require("easy-dotnet").setup({ ... })
end
```

### 6. Passing Nix Values to Lua

The `extra` field passes arbitrary data:

```nix
# In language module
extra = {
  roslynDLLPath = "${roslyn-ls}/lib/...";
  theme = "tokyonight";
}
```

```lua
-- In Lua
local roslynPath = nixCats.extra.roslynDLLPath
local theme = nixCats.extra.theme
```

---

## Directory Structure

```
nixcats/
├── default.nix              # mkNixCats builder function
│
├── languages/               # Language modules (Nix)
│   ├── default.nix          # Module loader & merger
│   ├── nix.nix              # Nix language
│   ├── dotnet.nix           # .NET/C#
│   ├── rust.nix             # Rust
│   ├── python.nix           # Python
│   ├── typescript.nix       # TypeScript/JavaScript
│   ├── json.nix             # JSON
│   ├── sql.nix              # SQL
│   ├── markdown.nix         # Markdown
│   ├── terraform.nix        # Terraform
│   ├── aws.nix              # AWS CloudFormation
│   ├── kotlin.nix           # Kotlin
│   ├── scala.nix            # Scala
│   ├── bash.nix             # Bash/Shell
│   └── docker.nix           # Docker
│
├── lua/                     # Neovim Lua configuration
│   ├── init.lua             # Entry point (loads plugins, languages)
│   └── lua/
│       ├── core/
│       │   ├── options.lua  # Vim options
│       │   └── keymaps.lua  # Core keybindings
│       │
│       ├── plugins/         # Plugin configurations
│       │   ├── init.lua     # Plugin loader
│       │   ├── lsp.lua      # LSP setup
│       │   ├── completion.lua
│       │   ├── telescope.lua
│       │   ├── treesitter.lua
│       │   ├── conform.lua
│       │   ├── git.lua
│       │   ├── ui.lua
│       │   ├── editor.lua
│       │   ├── dap.lua
│       │   ├── avante.lua
│       │   ├── copilot.lua
│       │   ├── ufo.lua
│       │   ├── illuminate.lua
│       │   ├── smart-splits.lua
│       │   ├── lint.lua
│       │   ├── zellij-nav.lua
│       │   └── snacks/
│       │       ├── init.lua
│       │       └── dashboard.lua
│       │
│       ├── languages/       # Language-specific Lua
│       │   ├── init.lua
│       │   └── dotnet/
│       │       └── dotnet.lua
│       │
│       └── lsp/             # LSP-specific configs
│           └── easy_dotnet.lua
│
└── docs/                    # Documentation
    ├── KEYBINDINGS.md
    ├── LANGUAGES.md
    └── ARCHITECTURE.md
```

---

## Plugin Categories

### Core Plugins (Always Loaded)

| Plugin | Purpose |
|--------|---------|
| plenary-nvim | Lua utility library |
| nvim-web-devicons | File icons |
| nvim-treesitter | Syntax highlighting |
| nvim-lspconfig | LSP framework |
| blink-cmp | Completion |
| telescope-nvim | Fuzzy finder |
| which-key-nvim | Key discovery |

### UI Plugins

| Plugin | Purpose |
|--------|---------|
| lualine-nvim | Status line |
| noice-nvim | UI improvements |
| neo-tree-nvim | File explorer |
| trouble-nvim | Diagnostics list |
| snacks-nvim | Dashboard & utilities |
| tabby-nvim | Tab bar |

### Editor Plugins

| Plugin | Purpose |
|--------|---------|
| flash-nvim | Enhanced motions |
| comment-nvim | Commenting |
| nvim-autopairs | Auto pairs |
| mini-nvim | Various utilities |
| indent-blankline-nvim | Indent guides |
| todo-comments-nvim | TODO highlighting |

### Git Plugins

| Plugin | Purpose |
|--------|---------|
| gitsigns-nvim | Git signs |
| lazygit-nvim | LazyGit integration |
| vscode-diff | Diff viewer |

### Optional Plugins (Category-gated)

| Plugin | Category |
|--------|----------|
| nvim-dap | debug |
| nvim-dap-ui | debug |
| rustaceanvim | languages.rust |
| crates-nvim | languages.rust |
| easy-dotnet-nvim | languages.dotnet |
| nvim-metals | languages.scala |

---

## Development Workflow

### Dev Mode

Use `wrapRc = false` for live reload:

```bash
nix run .#nixcats-dev
```

Edit files in `nixcats/lua/` and restart Neovim - no rebuild needed.

### Hermetic Mode

Use `wrapRc = true` (default) for reproducible builds:

```bash
nix build .#nixcats-full
```

Lua is baked into the derivation.

### Adding Features

1. **New plugin**: Add to `default.nix` `startupPlugins.general`
2. **New language**: Create `languages/{lang}.nix`, register in `default.nix`
3. **New keybinding**: Edit appropriate file in `lua/lua/plugins/`
4. **New category**: Add to `extraCategories` parameter

### Testing

```bash
# Build without switching
nix build .#nixcats-full --no-link

# Run the build
nix run .#nixcats-full

# Check health
:checkhealth

# View LSP status
:LspInfo
```

---

## Build Flow

```
flake.nix
    │
    ├── Apply overlay to pkgs
    │
    └── Call nixcatsLib.mkNixCats
            │
            ├── Load language modules
            │   └── Merge into categoryDefinitions
            │
            ├── Create packageDefinitions
            │   └── Settings: wrapRc, theme, etc.
            │
            └── nixCats.utils.baseBuilder
                    │
                    ├── Build Neovim with plugins
                    ├── Include LSPs and tools
                    └── Wrap Lua config (if wrapRc)
```

---

## Custom Packages

Custom packages are defined in `packages/`:

```
packages/
├── default.nix           # Package exports
├── vimPlugins/
│   ├── default.nix       # Custom vim plugins
│   ├── telescope-tabs.nix
│   ├── vscode-diff.nix
│   └── easy-dotnet.nix
├── kotlin-lsp.nix        # JetBrains Kotlin LSP
└── ...
```

These are added to the overlay and available as:
- `pkgs.customVimPlugins.{name}`
- `pkgs.kotlin-lsp`

---

## Integration with nixos-base

nixcats integrates with the broader nixos-base personal configuration:

```nix
# In host config
{
  personalConfig.users.myuser = {
    nvim = true;  # Enable nixcats
    languages = ["nix" "dotnet"];
  };
}
```

The home-manager module can reference the nixcats packages:

```nix
home.packages = [
  inputs.personalConfig.packages.${system}.nixcats-full
];
```

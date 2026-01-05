# nixcats

A [nixCats](https://github.com/BirdeeHub/nixCats-nvim)-based Neovim distribution with Lua-first philosophy and Nix reproducibility.

## Quick Start

```bash
# Full IDE (all languages)
nix run .#nixcats-full

# Minimal (nix language only)
nix run .#nixcats

# Dev mode (live Lua reload)
nix run .#nixcats-dev
```

## Package Variants

| Package | Languages | Use Case |
|---------|-----------|----------|
| `nixcats` | nix | Minimal Nix development |
| `nixcats-full` | nix, dotnet, rust, python, typescript, json, sql, terraform | Full-stack IDE |
| `nixcats-dev` | nix | Configuration development (live reload) |

## Features

- **Lua-first**: Standard Neovim Lua configuration, portable anywhere
- **Nix reproducibility**: Plugins, LSPs, and tools managed deterministically
- **Category-based loading**: Enable only the languages you need
- **Theme flexibility**: Choose tokyonight or catppuccin
- **Dev mode**: Edit Lua config without rebuilding

## Documentation

- [Keybindings Reference](docs/KEYBINDINGS.md) - Complete key mappings
- [Language Modules](docs/LANGUAGES.md) - Available languages and their tools
- [Architecture](docs/ARCHITECTURE.md) - How nixcats works internally

## Configuration

```nix
nixcatsLib.mkNixCats {
  system = "x86_64-linux";
  pkgs = unstablePkgs;
  stablePkgs = stablePkgs;

  # Languages to enable
  languages = [ "nix" "dotnet" "rust" ];

  # Theme: "tokyonight" (default) or "catppuccin"
  theme = "tokyonight";

  # Hermetic build (true) or dev mode (false)
  wrapRc = true;

  # Optional extras
  extraPlugins = [ ];
  extraPackages = [ ];
  extraCategories = { debug = true; };
}
```

## Available Languages

| Language | LSP | Formatter | Tools |
|----------|-----|-----------|-------|
| nix | nixd | alejandra | statix, deadnix |
| dotnet | roslyn-ls | csharpier | netcoredbg, dotnet-ef |
| rust | rust-analyzer | rustfmt | clippy |
| python | pyright | ruff, black | isort |
| typescript | ts_ls | prettier | eslint |
| json | jsonls | - | schemastore |
| sql | sqls | pgformatter | - |
| markdown | marksman | - | - |
| terraform | terraformls | - | - |
| kotlin | kotlin-lsp | ktlint | gradle |
| scala | metals | scalafmt | mill, sbt |
| bash | bashls | shfmt | shellcheck |
| docker | dockerls | - | hadolint |
| aws | yamlls | - | CloudFormation schemas |

See [Language Modules](docs/LANGUAGES.md) for details.

## Key Bindings Summary

Leader key: `<Space>`

| Category | Keys | Description |
|----------|------|-------------|
| Find | `<leader>ff` | Find files |
| Find | `<leader>fg` | Live grep |
| LSP | `gd` | Go to definition |
| LSP | `K` | Hover documentation |
| LSP | `<leader>la` | Code action |
| Git | `<leader>gg` | LazyGit |
| Debug | `<leader>db` | Toggle breakpoint |

See [Keybindings Reference](docs/KEYBINDINGS.md) for complete list.

## Adding a New Language

1. Create `languages/{lang}.nix`:
```nix
{ pkgs, stablePkgs, ... }:
{
  lspsAndRuntimeDeps = with pkgs; [ your-lsp ];
  startupPlugins = [ ];
  optionalPlugins = [ ];
  environmentVariables = { };
}
```

2. Register in `languages/default.nix`:
```nix
availableLanguages = {
  yourlang = ./yourlang.nix;
};
```

3. Add LSP config to `lua/lua/plugins/lsp.lua`:
```lua
if hasLang('yourlang') then
  table.insert(servers, 'yourlang_server')
  vim.lsp.config.yourlang_server = { capabilities = capabilities }
end
```

4. Test: `nix run .#nixcats-full`

See [Architecture](docs/ARCHITECTURE.md) for detailed guide.

## Directory Structure

```
nixcats/
├── default.nix              # mkNixCats builder
├── languages/               # Language modules (Nix)
│   ├── default.nix          # Module loader
│   ├── nix.nix
│   ├── dotnet.nix
│   └── ...
├── lua/                     # Neovim configuration (Lua)
│   ├── init.lua
│   └── lua/
│       ├── core/            # options.lua, keymaps.lua
│       ├── plugins/         # Plugin configurations
│       └── languages/       # Language-specific Lua
└── docs/                    # Documentation
```

## Development

### Dev Mode

Use `nixcats-dev` for live Lua reload:

```bash
nix run .#nixcats-dev
```

Edit `lua/**/*.lua` files - restart Neovim to see changes (no rebuild needed).

### Testing Changes

```bash
# Build without switching
nix build .#nixcats-full --no-link

# Run the build
nix run .#nixcats-full
```

## Comparison with nixvim

| Aspect | nixvim | nixcats |
|--------|--------|---------|
| Config style | Nix DSL | Native Lua |
| Plugin config | Nix options | Lua setup() calls |
| Portability | Nix-only | Lua portable anywhere |
| Learning curve | nixvim DSL | Standard Neovim |
| Dev workflow | Always rebuild | Dev mode available |

Both coexist during transition: `nix run .#nixvim` vs `nix run .#nixcats-full`

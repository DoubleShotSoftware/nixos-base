# nixcats Handoff Document

Current state and remaining work for the nixcats Neovim configuration.

## Status: Functional

nixcats is fully functional as a Lua-first alternative to nixvim. All core features work.

```bash
nix run .#nixcats-full   # Full IDE
nix run .#nixcats-dev    # Dev mode (live Lua reload)
```

---

## What's Been Done

### Core Infrastructure
- [x] mkNixCats builder function with language module system
- [x] Category-based plugin/LSP loading (`languages.X` categories)
- [x] Theme support (tokyonight, catppuccin)
- [x] Dev mode (wrapRc = false) for live Lua editing
- [x] Custom plugin packaging (overlay in flake.nix)

### Language Support (14 languages)
- [x] Nix (nixd, alejandra, statix, deadnix)
- [x] .NET/C# (roslyn-ls via easy-dotnet, csharpier, netcoredbg)
- [x] Rust (rust-analyzer, rustfmt, clippy, rustaceanvim)
- [x] Python (pyright, ruff, black)
- [x] TypeScript/JavaScript (ts_ls, prettier, eslint)
- [x] JSON (jsonls, schemastore)
- [x] SQL (sqls, pgformatter)
- [x] Markdown (marksman, render-markdown, preview)
- [x] Terraform (terraformls)
- [x] AWS/CloudFormation (yamlls with schemas)
- [x] Kotlin (kotlin-lsp from JetBrains)
- [x] Scala (metals, nvim-metals)
- [x] Bash (bashls, shellcheck, shfmt)
- [x] Docker (dockerls, docker-compose-ls, hadolint)

### Plugins Configured
- [x] LSP (nvim-lspconfig, fidget)
- [x] Completion (blink-cmp, colorful-menu)
- [x] Treesitter (all grammars, textobjects, context)
- [x] Telescope (fzf-native, telescope-tabs)
- [x] Git (gitsigns, lazygit, vscode-diff, git-worktree)
- [x] File explorer (neo-tree with AstroNvim-style config)
- [x] UI (lualine, noice, snacks dashboard, which-key)
- [x] Editor (flash, mini, todo-comments, indent-blankline)
- [x] Formatting (conform.nvim)
- [x] Linting (nvim-lint)
- [x] DAP debugging (nvim-dap, dap-ui, dap-virtual-text)
- [x] AI (avante, copilot)
- [x] Folding (nvim-ufo)
- [x] Window nav (smart-splits, zellij-nav)
- [x] Tabs (tabby.nvim)

### Custom Packages Built
- [x] `vscode-diff` - VS Code-style diff with native C library
- [x] `telescope-tabs` - Tab picker for telescope
- [x] `kotlin-lsp` - JetBrains Kotlin LSP from releases
- [x] `roslyn-nvim` - C# Roslyn LSP integration
- [x] `easy-dotnet` - .NET development plugin

### Documentation
- [x] README.md - Overview and quick start
- [x] docs/KEYBINDINGS.md - Complete keybinding reference
- [x] docs/LANGUAGES.md - Language module guide
- [x] docs/ARCHITECTURE.md - How nixcats works internally

---

## What's Missing (vs nixvim)

### High Priority - nixvim has these configured

| Feature | Plugin | Effort | Notes |
|---------|--------|--------|-------|
| **Terminal** | toggleterm | Medium | Float/split terminals, F7 toggle |
| **Better UI** | dressing.nvim | Easy | Makes vim.ui use telescope |
| **Sessions** | resession | Medium | Per-project session save/restore |

### Medium Priority - Common requests

| Feature | Plugin | Effort | Notes |
|---------|--------|--------|-------|
| Quick marks | harpoon | Easy | Instant file switching |
| Search/replace | spectre | Easy | Project-wide find/replace |
| Test runner | neotest | Medium | Run tests from editor |
| Code outline | aerial.nvim | Easy | Symbol sidebar |

### Low Priority - Niche but useful

| Feature | Plugin | Effort | Notes |
|---------|--------|--------|-------|
| Database | vim-dadbod | Medium | SQL in editor |
| HTTP client | rest.nvim | Easy | API testing |
| Peek definition | goto-preview | Easy | Float preview |

---

## Known Issues

### Status Bar Drift
nixvim uses default lualine, nixcats has custom config with:
- catppuccin theme
- Custom separators
- globalstatus = true
- .NET job indicator

Decision needed: sync them or keep different.

### Prunable Worktrees
`git worktree list` shows prunable entries from old paths. Run:
```bash
git worktree prune
```

---

## File Structure

```
nixcats/
├── default.nix              # mkNixCats builder
├── languages/               # Language modules (Nix)
│   ├── default.nix          # Module loader
│   ├── nix.nix
│   ├── dotnet.nix
│   ├── rust.nix
│   ├── python.nix
│   ├── typescript.nix
│   ├── json.nix
│   ├── sql.nix
│   ├── markdown.nix
│   ├── terraform.nix
│   ├── aws.nix
│   ├── kotlin.nix
│   ├── scala.nix
│   ├── bash.nix
│   └── docker.nix
├── lua/                     # Neovim Lua config
│   ├── init.lua             # Entry point
│   └── lua/
│       ├── core/
│       │   ├── options.lua
│       │   └── keymaps.lua
│       ├── plugins/         # Plugin configs
│       │   ├── init.lua     # Plugin loader
│       │   ├── lsp.lua
│       │   ├── completion.lua
│       │   ├── telescope.lua
│       │   ├── git.lua
│       │   ├── git_worktree.lua
│       │   ├── ui.lua
│       │   ├── dap.lua
│       │   └── ...
│       └── languages/       # Language-specific Lua
│           └── dotnet/
└── docs/
    ├── KEYBINDINGS.md
    ├── LANGUAGES.md
    └── ARCHITECTURE.md

packages/
├── vimPlugins/
│   ├── default.nix          # Plugin exports
│   ├── vscode-diff.nix      # With native C build
│   ├── telescope-tabs.nix
│   ├── roslyn-nvim.nix
│   └── easy-dotnet.nix
└── kotlin-lsp.nix           # JetBrains LSP
```

---

## How to Add Features

### Adding a Plugin

1. Add to `nixcats/default.nix` in `startupPlugins.general`:
```nix
# In the `with pkgs.vimPlugins;` block
toggleterm-nvim
```

2. Create config file `nixcats/lua/lua/plugins/{plugin}.lua`

3. Add require to `nixcats/lua/lua/plugins/init.lua`:
```lua
require('plugins.{plugin}')
```

4. Update `docs/KEYBINDINGS.md` if adding keymaps

### Adding a Language

See `docs/LANGUAGES.md` for full guide. Quick version:

1. Create `nixcats/languages/{lang}.nix`
2. Register in `nixcats/languages/default.nix`
3. Add LSP config to `nixcats/lua/lua/plugins/lsp.lua`
4. Add formatter to `nixcats/lua/lua/plugins/conform.lua`

### Custom Plugin Packaging

For plugins not in nixpkgs, create in `packages/vimPlugins/`:

```nix
# packages/vimPlugins/my-plugin.nix
{pkgs}:
  pkgs.vimUtils.buildVimPlugin {
    pname = "my-plugin";
    version = "...";
    src = pkgs.fetchFromGitHub {
      owner = "...";
      repo = "...";
      rev = "...";
      hash = "...";
    };
  }
```

Add to `packages/vimPlugins/default.nix` and reference as `pkgs.customVimPlugins.my-plugin`.

---

## Testing

```bash
# Build without installing
nix build .#nixcats-full --no-link

# Run directly
nix run .#nixcats-full

# Dev mode (edit lua, restart nvim, no rebuild)
nix run .#nixcats-dev

# Check health
:checkhealth

# LSP status
:LspInfo

# Check loaded plugins
:Lazy
```

---

## Key Keybindings

| Key | Action |
|-----|--------|
| `<Space>` | Leader |
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>e` | File explorer |
| `gd` | Go to definition |
| `K` | Hover docs |
| `<leader>la` | Code action |
| `<leader>gg` | LazyGit |
| `<leader>gw` | Git worktrees |
| `<leader>db` | Toggle breakpoint |

See `docs/KEYBINDINGS.md` for complete list.

---

## Recent Changes (This Session)

1. Fixed vscode-diff native library build (CMake in Nix)
2. Added git-worktree support with telescope integration
3. Added `<leader>gU` for setting upstream branch
4. Created comprehensive documentation

---

## Contact / Resources

- nixCats upstream: https://github.com/BirdeeHub/nixCats-nvim
- This repo: nixos-base (branch: 25_11_nixcats_dotnet)

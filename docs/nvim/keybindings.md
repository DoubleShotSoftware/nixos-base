# Keybindings

`<leader>` is Space. This is a useful, verified subset rather than an exhaustive map; use which-key and the [configuration source](../../nixcats/lua/lua/) for all mappings. See [.NET and C#](dotnet.md) and [Git integration](git.md) for scoped bindings.

## Core

| Key | Action |
| --- | --- |
| `<leader>w` / `<leader>W` | Save current file / all files |
| `<leader>q` / `<leader>Q` | Quit / force quit all |
| `<leader>bc` / `<leader>bC` | Close buffer / force close buffer |
| `<leader>U` | Open undo tree |
| `<C-h>` `<C-j>` `<C-k>` `<C-l>` | Move between windows |
| `[t` / `]t` | Previous / next tab |
| `<C-Up>` `<C-Down>` | Increase / decrease window height |
| `<C-Left>` `<C-Right>` | Increase / decrease window width |
| `<A-j>` / `<A-k>` | Move line or visual selection down / up |
| `<Esc>` | Clear search highlighting |

## LSP

The LSP navigation and action mappings are buffer-local after an LSP attaches.

| Key | Action |
| --- | --- |
| `gd`, `gD`, `gi`, `gr`, `gy` | Definition, declaration, implementation, references, type definition |
| `K` / `gl` | Hover documentation / signature help |
| `<leader>la` / `<leader>lR` | Code action / rename symbol |
| `<leader>lr` | References |
| `<leader>li` | LSP health check |
| `<leader>ld`, `[d`, `]d` | Line diagnostics, previous diagnostic, next diagnostic |
| `<leader>ll` / `<leader>lL` | Refresh / run CodeLens |
| `<leader>lo` | LSP outline |
| `<leader>lk` / `<leader>lD` | Saga hover / line diagnostics |
| `<leader>lF` | LSP finder |
| `<leader>lp` / `<leader>lP` | Peek definition / type definition |
| `<leader>lci` / `<leader>lco` | Incoming / outgoing calls |

## Formatting

| Key | Action |
| --- | --- |
| `<leader>lf` | Format with LSP preferred, then formatter fallback |
| `<leader>bf` | Format with an external formatter only |

## Upstream

- [which-key.nvim](https://github.com/folke/which-key.nvim)

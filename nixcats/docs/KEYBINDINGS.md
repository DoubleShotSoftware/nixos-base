# Keybindings Reference

Leader key: `<Space>`

## Navigation & Search

### Telescope

| Key | Description |
|-----|-------------|
| `<leader>ff` | Find files |
| `<leader>fF` | Find all files (including hidden) |
| `<leader>fg` | Live grep |
| `<leader>fw` | Find word under cursor |
| `<leader>fb` | Find buffers |
| `<leader>fh` | Help tags |
| `<leader>fr` | Recent files |
| `<leader>fd` | Diagnostics |
| `<leader>fs` | Document symbols |
| `<leader>fS` | Workspace symbols |
| `<leader>ft` | Find TODOs |
| `<leader>/` | Search in current buffer |

### Flash (Motion)

| Key | Description |
|-----|-------------|
| `s` | Flash jump |
| `S` | Flash treesitter |
| `r` | Remote flash (operator pending) |
| `R` | Treesitter search |

## LSP

### Navigation

| Key | Description |
|-----|-------------|
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gi` | Go to implementation |
| `gr` | Go to references |
| `gy` | Go to type definition |

### Information

| Key | Description |
|-----|-------------|
| `K` | Hover documentation |
| `gl` | Signature help |

### Actions

| Key | Description |
|-----|-------------|
| `<leader>la` | Code action |
| `<leader>lR` | Rename symbol |
| `<leader>lr` | References (Telescope) |
| `<leader>li` | LSP info |
| `<leader>ll` | CodeLens refresh |
| `<leader>lL` | CodeLens run |

### Diagnostics

| Key | Description |
|-----|-------------|
| `<leader>ld` | Line diagnostics (float) |
| `[d` | Previous diagnostic |
| `]d` | Next diagnostic |
| `<leader>lx` | Diagnostics list (Trouble) |
| `<leader>lo` | Outline/symbols (Trouble) |

### Formatting

| Key | Description |
|-----|-------------|
| `<leader>bf` | Format buffer |

## Git

### Gitsigns

| Key | Description |
|-----|-------------|
| `]h` | Next hunk |
| `[h` | Previous hunk |
| `<leader>gs` | Stage hunk |
| `<leader>gr` | Reset hunk |
| `<leader>gS` | Stage buffer |
| `<leader>gu` | Undo stage hunk |
| `<leader>gR` | Reset buffer |
| `<leader>gp` | Preview hunk |
| `<leader>gb` | Blame line (full) |
| `<leader>gB` | Toggle line blame |
| `<leader>gd` | Diff this |
| `<leader>gD` | Diff this ~ |

### Diff & History

| Key | Description |
|-----|-------------|
| `<leader>gv` | Open diff (vscode-diff) |
| `<leader>gc` | Close diff |
| `<leader>gh` | File history |
| `<leader>gC` | Buffer commits (Telescope) |
| `<leader>gl` | Git log (Telescope) |
| `<leader>gf` | Git status files (Telescope) |

### LazyGit

| Key | Description |
|-----|-------------|
| `<leader>gg` | Open LazyGit |

### Worktree

| Key | Description |
|-----|-------------|
| `<leader>gw` | Git worktrees (telescope) |
| `<leader>gW` | Create new worktree |
| `<leader>gU` | Set upstream branch |

## Debug (DAP)

### Breakpoints

| Key | Description |
|-----|-------------|
| `<leader>db` | Toggle breakpoint |
| `<leader>dB` | Conditional breakpoint |
| `<leader>dl` | Log point |

### Execution

| Key | Description |
|-----|-------------|
| `<leader>dc` | Continue |
| `<leader>dC` | Run to cursor |
| `<leader>ds` | Step over |
| `<leader>di` | Step into |
| `<leader>do` | Step out |
| `<leader>dp` | Pause |

### Session

| Key | Description |
|-----|-------------|
| `<leader>dr` | Restart |
| `<leader>dt` | Terminate |
| `<leader>dd` | Disconnect |

### UI

| Key | Description |
|-----|-------------|
| `<leader>du` | Toggle DAP UI |
| `<leader>de` | Eval expression |
| `<leader>dR` | Toggle REPL |

## Window Management

### Navigation (smart-splits)

| Key | Description |
|-----|-------------|
| `<C-h>` | Move to left split |
| `<C-j>` | Move to below split |
| `<C-k>` | Move to above split |
| `<C-l>` | Move to right split |

### Resizing

| Key | Description |
|-----|-------------|
| `<C-Up>` | Resize split up |
| `<C-Down>` | Resize split down |
| `<C-Left>` | Resize split left |
| `<C-Right>` | Resize split right |

## Buffer Management

| Key | Description |
|-----|-------------|
| `<leader>bc` | Close buffer |
| `<leader>bC` | Force close buffer |
| `<leader>w` | Save file |
| `<leader>W` | Save all files |
| `<leader>q` | Quit |
| `<leader>Q` | Force quit all |

## Tabs

| Key | Description |
|-----|-------------|
| `[t` | Previous tab |
| `]t` | Next tab |
| `<leader>Tn` | New tab |
| `<leader>Tc` | Close tab |
| `<leader>To` | Close other tabs |
| `<leader>Tmh` | Move tab left |
| `<leader>Tml` | Move tab right |

## File Explorer (Neo-tree)

| Key | Description |
|-----|-------------|
| `<leader>e` | Toggle file explorer |
| `<leader>o` | Focus file explorer |

### Within Neo-tree

| Key | Description |
|-----|-------------|
| `h` | Parent directory / collapse |
| `l` | Child / expand / open |
| `Y` | Copy path selector |
| `F` | Find file in directory |
| `W` | Grep in directory |
| `[b` | Previous source (Files/Bufs/Git) |
| `]b` | Next source |
| `<C-j>` | Move cursor down (fuzzy finder) |
| `<C-k>` | Move cursor up (fuzzy finder) |

## References (illuminate)

| Key | Description |
|-----|-------------|
| `]r` | Next reference |
| `[r` | Previous reference |
| `<leader>ur` | Toggle highlighting (buffer) |
| `<leader>uR` | Toggle highlighting (global) |

## Code Folding (ufo)

| Key | Description |
|-----|-------------|
| `zR` | Open all folds |
| `zM` | Close all folds |
| `zr` | Open folds (level) |
| `zm` | Close folds (level) |
| `zp` | Peek fold preview |

## UI Toggles

| Key | Description |
|-----|-------------|
| `<leader>uC` | Pick colorscheme |
| `<Esc>` | Clear search highlights |

## Markdown

| Key | Description |
|-----|-------------|
| `<leader>mp` | Toggle markdown preview |

## Language-Specific

### .NET (when languages.dotnet enabled)

| Key | Description |
|-----|-------------|
| `<leader>lbe` | Dotnet commands menu |
| `<leader>lbb` | Build (quickfix) |
| `<leader>lbr` | Restore |
| `<leader>lbc` | Clean |
| `<leader>lbt` | Test runner |
| `<leader>lbd` | Debug |

### Rust (when languages.rust enabled)

Uses rustaceanvim defaults plus standard LSP keybindings.

## Which-Key Groups

Press `<leader>` and wait to see available groups:

| Group | Prefix | Description |
|-------|--------|-------------|
| Buffer | `<leader>b` | Buffer operations |
| Find | `<leader>f` | Telescope searches |
| Git | `<leader>g` | Git operations |
| LSP | `<leader>l` | Language server |
| Language | `<leader>lb` | Language-specific |
| Tabs | `<leader>T` | Tab management |
| UI | `<leader>u` | UI toggles |
| Debug | `<leader>d` | DAP debugging |

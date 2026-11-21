# Git Integration

`<leader>` is Space. Gitsigns mappings below are buffer-local: they exist only in buffers attached by Gitsigns. Other mappings are global unless their optional plugin is unavailable.

## Gitsigns

| Key | Action |
| --- | --- |
| `]h` / `[h` | Next / previous hunk |
| `<leader>gs` | Stage hunk; stages selected lines in visual mode |
| `<leader>gS` / `<leader>gu` | Stage buffer / undo staged hunk |
| `<leader>gr` | Reset hunk; resets selected lines in visual mode |
| `<leader>gR` | Reset buffer |
| `<leader>gp` | Preview hunk |
| `<leader>gb` / `<leader>gB` | Toggle inline blame / full line blame |
| `<leader>gd` | Diff current buffer against `HEAD` |

## Diffview

| Key | Action |
| --- | --- |
| `<leader>gv` / `<leader>gq` | Open / close Diffview |
| `<leader>gh` / `<leader>gH` | File / repository history |
| `<leader>gD` | Prompt for a ref and open Diffview against it |
| `<leader>gc` | Open CodeDiff split view |

## DeltaView

| Key | Action |
| --- | --- |
| `<leader>gl` / `<leader>gL` | Open DeltaView / select files with DeltaMenu |
| `<leader>gV` | Prompt for a ref and open DeltaView against it |

## Worktree

When `git-worktree` and Telescope load, these mappings use its Telescope extension.

| Key | Action |
| --- | --- |
| `<leader>gw` / `<leader>gW` | Switch / create worktree |

## Telescope

When Telescope loads:

| Key | Action |
| --- | --- |
| `<leader>gC` / `<leader>gf` | All commits / commits for current file |
| `<leader>gt` | Branches |
| `<leader>gF` | Git status files |

`<leader>gx` prompts for deleted files in Git history and shows the results in Telescope when available, otherwise in quickfix.

## LazyGit

| Key | Action |
| --- | --- |
| `<leader>gg` | Open LazyGit |

## Browser

When Snacks provides `gitbrowse`:

| Key | Action |
| --- | --- |
| `<leader>go` | Open the current Git context in a browser |

## Upstream

- [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim)
- [diffview.nvim](https://github.com/sindrets/diffview.nvim)
- [codediff.nvim](https://github.com/esmuellert/codediff.nvim)
- [deltaview.nvim](https://github.com/kokusenz/deltaview.nvim)
- [git-worktree.nvim](https://github.com/ThePrimeagen/git-worktree.nvim)
- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
- [lazygit](https://github.com/jesseduffield/lazygit)
- [snacks.nvim](https://github.com/folke/snacks.nvim)

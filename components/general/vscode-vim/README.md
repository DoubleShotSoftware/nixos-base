# VSCode NeoVim Integration

This component provides VSCode-compatible keybinding integration for NeoVim, allowing you to use the same keybindings in both standalone NeoVim and VSCode's NeoVim extension.

## Features

- Preserves your nixvim keybindings when running inside VSCode
- Routes commands to VSCode's native features (search, git, LSP, debugger)
- Keeps core editing behavior (window navigation, text manipulation) native to NeoVim
- Zero impact on standalone NeoVim configuration

## Usage

### 1. Enable in User Configuration

Add to your user config:

```nix
personalConfig.users.yourname = {
  nvim = true;
  vscode = true;
  vscodeVimConfig = true;  # Enable VSCode integration
};
```

### 2. Configure VSCode Settings

In VSCode, open your `settings.json` and add:

```json
{
  "vscode-neovim.neovimInitVimPaths.darwin": "~/.config/vscode-nvim.lua",
  "vscode-neovim.neovimInitVimPaths.linux": "~/.config/vscode-nvim.lua",
  "extensions.experimental.affinity": {
    "asvetliakov.vscode-neovim": 1
  }
}
```

### 3. Rebuild

```bash
# For NixOS
nixos-rebuild switch

# For standalone home-manager
home-manager switch

# For macOS with nix-darwin
darwin-rebuild switch
```

## Keybinding Reference

All keybindings use `<Space>` as the leader key.

### Window Navigation
- `<C-h/j/k/l>` - Navigate between splits (native NeoVim behavior)

### Buffers (`<leader>b`)
- `<leader>bc` - Close buffer
- `<leader>w` - Save file
- `<leader>q` - Close window
- `<leader>n` - New file

### Find (`<leader>f`)
- `<leader>ff` - Find files
- `<leader>fw` - Find words (live grep)
- `<leader>fb` - Find buffers
- `<leader>fh` - Command palette
- `<leader>f/` - Find in current buffer

### LSP (`<leader>l`)
- `K` - Hover documentation
- `gd` - Go to definition
- `gr` - Go to references
- `gI` - Go to implementation
- `<leader>la` - Code actions
- `<leader>lr` - Rename symbol
- `<leader>lf` - Format document
- `]d` / `[d` - Next/previous diagnostic

### Git (`<leader>g`)
- `<leader>gg` - Open source control
- `<leader>gc` - Git commit
- `<leader>gp` - Git push
- `<leader>gb` - Git branches
- `<leader>gd` - Git diff

### Debugger (`<leader>d`)
- `<leader>db` - Toggle breakpoint
- `<leader>dc` - Continue
- `<leader>di` - Step into
- `<leader>do` - Step out
- `<leader>ds` - Start debugger

### Explorer
- `<leader>e` - Toggle file explorer

### Terminal (`<leader>t`)
- `<leader>tt` - Toggle terminal
- `<F7>` - Toggle terminal

### UI (`<leader>u`)
- `<leader>uz` - Toggle zen mode
- `<leader>us` - Toggle sidebar

## How It Works

The component:
1. Checks if `vscodeVimConfig` is enabled for a user
2. Creates `~/.config/vscode-nvim.lua` in the user's home directory
3. The Lua file checks `vim.g.vscode` to determine if running inside VSCode
4. When inside VSCode, keybindings route to VSCode commands via `vscode.call()`
5. Standalone NeoVim is unaffected and uses your regular nixvim config

## Customization

Edit `components/general/vscode-vim/vscode-nvim.lua` to add or modify keybindings.

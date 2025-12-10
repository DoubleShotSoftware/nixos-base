# Nixvim Working Session - Easy-dotnet & Startup Errors Fix

## Current Status
Working on fixing Neovim startup errors and easy-dotnet.nvim keybinding issues after a nixvim bump.

## Issues Identified

### 1. Astrocore Dependencies (FIXED)
- **Problem**: Multiple plugins were trying to use `astrocore` module which isn't available
- **Affected files**:
  - `nixvim/plugins/illuminate.nix` - Used `astrocore.buffer.is_valid()`
  - `nixvim/plugins/neo-tree.nix` - Used `astrocore.notify()`
- **Fix Applied**:
  - Replaced astrocore functions with native Neovim API calls
  - `illuminate.nix`: Changed to use `vim.api.nvim_buf_is_valid()`
  - `neo-tree.nix`: Changed to use `vim.notify()`

### 2. Easy-dotnet Tool Missing (FIXED)
- **Problem**: The EasyDotnet CLI tool wasn't available in PATH
- **Solution**:
  - Created Nix package at `packages/easy-dotnet-tool.nix`
  - Package details:
    - Version: 2.1.15
    - NuGet package: EasyDotnet
    - Installs as: `dotnet-easydotnet`
  - Added to nixvim extraPackages in `nixvim/plugins/easy-dotnet.nix`

### 3. Easy-dotnet Keybinding Issues (Previously Fixed)
- **Problem**: `<leader>bb` and `<leader>be` weren't working
- **Root Cause**: Plugin uses `Dotnet` command, not `DotnetUI`
- **Fix**: Updated commands in `nixvim/plugins/easy-dotnet.nix`:
  - `<leader>be` → `Dotnet` (command picker)
  - `<leader>bb` → `Dotnet build` (build with picker)

### 4. Dashboard ASCII Art
- **Status**: Original ASCII art is preserved in `nixvim/lua/alpha.lua`
- **Note**: User reported not seeing it properly - likely a rendering issue, not a code issue

## Files Modified in This Session

1. `/home/sobrien/dev/nixos-base/nixvim/plugins/illuminate.nix`
   - Removed astrocore dependency
   - Set largeFileCutoff to 2000 lines
   - Simplified buffer validation

2. `/home/sobrien/dev/nixos-base/nixvim/plugins/neo-tree.nix`
   - Replaced `require("astrocore").notify` with `vim.notify`

3. `/home/sobrien/dev/nixos-base/nixvim/plugins/easy-dotnet.nix`
   - Added easy-dotnet-tool to extraPackages
   - Already has proper keybindings and dotnetSDK configuration

## Testing Required

After reboot and rebuild:
1. Run `nix build .#nixvim` to build the configuration
2. Test with `./result/bin/nvim --headless +quit` to check for startup errors
3. Open a .NET project and test:
   - `<leader>be` - Should open Dotnet command picker
   - `<leader>bb` - Should open build project picker
   - `<leader>bq` - Should build with quickfix
4. Check if `dotnet-easydotnet` is available in PATH within Neovim

## Known Remaining Issues

### LSP Warnings (Non-critical)
- Roslyn-ls shows warnings about Razor file support and file watching
- These are informational only and don't affect functionality
- From `lsp.log`:
  ```
  [initialized] RazorDynamicFileInfoProvider not initialized
  [solution/open] Unable to use LSP file watching; falling back to in-process watcher
  ```

## Next Steps

1. **After reboot**:
   - Run `sudo nixos-rebuild switch --flake .#<hostname>`
   - Or if using home-manager: `home-manager switch --flake .#<username>@<hostname>`

2. **Verify fixes**:
   - Check that Neovim starts without errors
   - Test easy-dotnet keybindings work
   - Confirm `which dotnet-easydotnet` shows the tool is available

3. **If issues persist**:
   - Check if overlay is properly configured to include custom packages
   - Verify that the easy-dotnet-tool package builds correctly
   - Review any new error messages in startup

## Package Structure Notes

The custom packages are organized as:
- `packages/default.nix` - Exports all custom packages
- `packages/easy-dotnet-tool.nix` - EasyDotnet CLI tool package
- These are included in the overlay via `customPackages` in `flake.nix`

## Unified DotnetSDK
The flake defines a unified `dotnetSDK` in the overlay that combines:
- sdk_8_0-bin
- sdk_9_0-bin

This is used throughout the configuration to ensure consistency.
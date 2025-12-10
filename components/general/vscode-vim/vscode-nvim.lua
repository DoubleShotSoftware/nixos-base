-- VSCode NeoVim Integration Configuration
-- This file is loaded when running inside VSCode's NeoVim extension
-- Set this path in VSCode settings: "vscode-neovim.neovimInitVimPaths.darwin": "~/.config/vscode-nvim.lua"

-- Only load this config if running in VSCode
if not vim.g.vscode then
  return
end

-- Set leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Helper function to call VSCode commands
local vscode = require('vscode')
local function vscodeCall(command)
  return function()
    vscode.call(command)
  end
end

-- Helper for calling with arguments
local function vscodeCallArgs(command, args)
  return function()
    vscode.call(command, args)
  end
end

-- Keybinding helper
local function map(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then
    options = vim.tbl_extend('force', options, opts)
  end
  vim.keymap.set(mode, lhs, rhs, options)
end

-- ============================================================================
-- Window Navigation (keep native NeoVim behavior, works well with VSCode)
-- ============================================================================
map('n', '<C-h>', '<C-w>h', { desc = 'Move to left window' })
map('n', '<C-j>', '<C-w>j', { desc = 'Move to window below' })
map('n', '<C-k>', '<C-w>k', { desc = 'Move to window above' })
map('n', '<C-l>', '<C-w>l', { desc = 'Move to right window' })

-- ============================================================================
-- Buffer Management
-- ============================================================================
map('n', '<leader>bc', vscodeCall('workbench.action.closeActiveEditor'), { desc = 'Close buffer' })
map('n', '<leader>bC', vscodeCall('workbench.action.closeActiveEditor'), { desc = 'Force close buffer' })
map('n', '<leader>w', vscodeCall('workbench.action.files.save'), { desc = 'Save file' })
map('n', '<leader>q', vscodeCall('workbench.action.closeActiveEditor'), { desc = 'Close window' })
map('n', '<leader>n', vscodeCall('workbench.action.files.newUntitledFile'), { desc = 'New file' })

-- ============================================================================
-- Tab Navigation
-- ============================================================================
map('n', ']t', vscodeCall('workbench.action.nextEditor'), { desc = 'Next tab' })
map('n', '[t', vscodeCall('workbench.action.previousEditor'), { desc = 'Previous tab' })

-- ============================================================================
-- Text Manipulation (keep native, works well)
-- ============================================================================
map('n', '<A-j>', '<cmd>move .+1<CR>==', { desc = 'Move line down' })
map('n', '<A-k>', '<cmd>move .-2<CR>==', { desc = 'Move line up' })
map('v', '<A-j>', ":move '>+1<CR>gv=gv", { desc = 'Move selection down' })
map('v', '<A-k>', ":move '<-2<CR>gv=gv", { desc = 'Move selection up' })

-- Stay in visual mode while indenting
map('v', '<', '<gv', { desc = 'Indent left' })
map('v', '>', '>gv', { desc = 'Indent right' })
map('v', '<Tab>', '>gv', { desc = 'Indent right' })
map('v', '<S-Tab>', '<gv', { desc = 'Indent left' })

-- ============================================================================
-- Find (Telescope equivalent) - <leader>f
-- ============================================================================
map('n', '<leader>ff', vscodeCall('workbench.action.quickOpen'), { desc = 'Find files' })
map('n', '<leader>fw', vscodeCall('workbench.action.findInFiles'), { desc = 'Find words (live grep)' })
map('n', '<leader>fo', vscodeCall('workbench.action.quickOpen'), { desc = 'Find old files' })
map('n', '<leader>fb', vscodeCall('workbench.action.showAllEditors'), { desc = 'Find buffers' })
map('n', '<leader>fh', vscodeCall('workbench.action.showCommands'), { desc = 'Find help (command palette)' })
map('n', '<leader>fk', vscodeCall('workbench.action.openGlobalKeybindings'), { desc = 'Find keymaps' })
map('n', '<leader>fm', vscodeCall('workbench.action.gotoSymbol'), { desc = 'Find marks/symbols' })
map('n', '<leader>f/', vscodeCall('actions.find'), { desc = 'Find in current buffer' })
map('n', '<leader>fc', vscodeCall('workbench.action.findInFiles'), { desc = 'Find word under cursor' })

-- ============================================================================
-- LSP / Language Tools - <leader>l
-- ============================================================================
map('n', 'K', vscodeCall('editor.action.showHover'), { desc = 'Hover documentation' })
map('n', 'gd', vscodeCall('editor.action.revealDefinition'), { desc = 'Go to definition' })
map('n', 'gD', vscodeCall('editor.action.revealDeclaration'), { desc = 'Go to declaration' })
map('n', 'gr', vscodeCall('editor.action.goToReferences'), { desc = 'Go to references' })
map('n', 'gI', vscodeCall('editor.action.goToImplementation'), { desc = 'Go to implementation' })
map('n', 'gy', vscodeCall('editor.action.goToTypeDefinition'), { desc = 'Go to type definition' })

map('n', '<leader>la', vscodeCall('editor.action.quickFix'), { desc = 'Code action' })
map('n', '<leader>lr', vscodeCall('editor.action.rename'), { desc = 'Rename symbol' })
map('n', '<leader>lf', vscodeCall('editor.action.formatDocument'), { desc = 'Format document' })
map('n', '<leader>ls', vscodeCall('workbench.action.gotoSymbol'), { desc = 'Document symbols' })
map('n', '<leader>lS', vscodeCall('workbench.action.showAllSymbols'), { desc = 'Workspace symbols' })
map('n', '<leader>li', vscodeCall('workbench.action.showRuntimeExtensions'), { desc = 'LSP info' })

-- Diagnostics
map('n', ']d', vscodeCall('editor.action.marker.nextInFiles'), { desc = 'Next diagnostic' })
map('n', '[d', vscodeCall('editor.action.marker.prevInFiles'), { desc = 'Previous diagnostic' })
map('n', '<leader>ld', vscodeCall('workbench.actions.view.problems'), { desc = 'Show diagnostics' })

-- ============================================================================
-- Git - <leader>g
-- ============================================================================
map('n', '<leader>gg', vscodeCall('workbench.view.scm'), { desc = 'Open git (source control)' })
map('n', '<leader>gc', vscodeCall('git.commit'), { desc = 'Git commit' })
map('n', '<leader>gp', vscodeCall('git.push'), { desc = 'Git push' })
map('n', '<leader>gP', vscodeCall('git.pull'), { desc = 'Git pull' })
map('n', '<leader>gb', vscodeCall('git.checkout'), { desc = 'Git branches' })
map('n', '<leader>gs', vscodeCall('git.stage'), { desc = 'Git stage' })
map('n', '<leader>gu', vscodeCall('git.unstage'), { desc = 'Git unstage' })
map('n', '<leader>gd', vscodeCall('git.openChange'), { desc = 'Git diff' })
map('n', '<leader>gB', vscodeCall('gitlens.toggleLineBlame'), { desc = 'Toggle git blame' })

-- ============================================================================
-- Debugger - <leader>d
-- ============================================================================
map('n', '<leader>db', vscodeCall('editor.debug.action.toggleBreakpoint'), { desc = 'Toggle breakpoint' })
map('n', '<leader>dc', vscodeCall('workbench.action.debug.continue'), { desc = 'Continue' })
map('n', '<leader>di', vscodeCall('workbench.action.debug.stepInto'), { desc = 'Step into' })
map('n', '<leader>do', vscodeCall('workbench.action.debug.stepOut'), { desc = 'Step out' })
map('n', '<leader>dO', vscodeCall('workbench.action.debug.stepOver'), { desc = 'Step over' })
map('n', '<leader>dr', vscodeCall('workbench.action.debug.restart'), { desc = 'Restart debugger' })
map('n', '<leader>ds', vscodeCall('workbench.action.debug.start'), { desc = 'Start debugger' })
map('n', '<leader>dt', vscodeCall('workbench.action.debug.stop'), { desc = 'Stop debugger' })
map('n', '<leader>du', vscodeCall('workbench.view.debug'), { desc = 'Show debug UI' })

-- ============================================================================
-- File Explorer - <leader>e
-- ============================================================================
map('n', '<leader>e', vscodeCall('workbench.view.explorer'), { desc = 'Toggle file explorer' })
map('n', '<leader>o', vscodeCall('workbench.view.explorer'), { desc = 'Open file explorer' })

-- ============================================================================
-- Terminal - <leader>t
-- ============================================================================
map('n', '<leader>tt', vscodeCall('workbench.action.terminal.toggleTerminal'), { desc = 'Toggle terminal' })
map('n', '<leader>tn', vscodeCall('workbench.action.terminal.new'), { desc = 'New terminal' })
map('n', '<leader>tf', vscodeCall('workbench.action.terminal.focus'), { desc = 'Focus terminal' })
map('n', '<F7>', vscodeCall('workbench.action.terminal.toggleTerminal'), { desc = 'Toggle terminal' })

-- ============================================================================
-- UI/UX - <leader>u
-- ============================================================================
map('n', '<leader>uz', vscodeCall('workbench.action.toggleZenMode'), { desc = 'Toggle zen mode' })
map('n', '<leader>uf', vscodeCall('workbench.action.toggleFullScreen'), { desc = 'Toggle fullscreen' })
map('n', '<leader>us', vscodeCall('workbench.action.toggleSidebarVisibility'), { desc = 'Toggle sidebar' })
map('n', '<leader>up', vscodeCall('workbench.action.togglePanel'), { desc = 'Toggle panel' })

-- ============================================================================
-- Splits
-- ============================================================================
map('n', '|', vscodeCall('workbench.action.splitEditorRight'), { desc = 'Split right' })
map('n', '\\', vscodeCall('workbench.action.splitEditorDown'), { desc = 'Split down' })

-- ============================================================================
-- Comments (using VSCode's native commenting)
-- ============================================================================
map('n', 'gcc', vscodeCall('editor.action.commentLine'), { desc = 'Toggle comment line' })
map('v', 'gc', vscodeCall('editor.action.commentLine'), { desc = 'Toggle comment' })

-- ============================================================================
-- Notification
-- ============================================================================
print("VSCode NeoVim keybindings loaded!")

-- nixcats/lua/core/keymaps.lua
-- Core keybindings (non-plugin specific)

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Disable space in normal mode (leader key)
map('', '<Space>', '<Nop>', opts)

-- Buffer management
map('n', '<leader>bc', ':bdelete<CR>', { desc = 'Close buffer' })
map('n', '<leader>bC', ':bdelete!<CR>', { desc = 'Force close buffer' })

-- Window navigation
map('n', '<C-h>', '<C-w>h', { desc = 'Move to left window' })
map('n', '<C-j>', '<C-w>j', { desc = 'Move to bottom window' })
map('n', '<C-k>', '<C-w>k', { desc = 'Move to top window' })
map('n', '<C-l>', '<C-w>l', { desc = 'Move to right window' })

-- Tab navigation
map('n', '[t', '<cmd>tabprevious<CR>', { desc = 'Previous tab' })
map('n', ']t', '<cmd>tabnext<CR>', { desc = 'Next tab' })

-- Window resizing
map('n', '<C-Up>', '<cmd>resize +4<CR>', { desc = 'Increase window height' })
map('n', '<C-Down>', '<cmd>resize -4<CR>', { desc = 'Decrease window height' })
map('n', '<C-Left>', '<cmd>vertical resize +4<CR>', { desc = 'Increase window width' })
map('n', '<C-Right>', '<cmd>vertical resize -4<CR>', { desc = 'Decrease window width' })

-- Move lines up/down
map('n', '<A-j>', '<cmd>move .+1<CR>==', { desc = 'Move line down' })
map('n', '<A-k>', '<cmd>move .-2<CR>==', { desc = 'Move line up' })
map('v', '<A-j>', ":move '>+1<CR>gv=gv", { desc = 'Move selection down' })
map('v', '<A-k>', ":move '<-2<CR>gv=gv", { desc = 'Move selection up' })

-- Stay in visual mode while indenting
map('v', '<', '<gv', { desc = 'Indent left' })
map('v', '>', '>gv', { desc = 'Indent right' })

-- Better paste (don't yank replaced text)
map('v', 'p', '"_dP', { desc = 'Paste without yanking' })

-- Clear search highlights
map('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlights' })

-- Quick save
map('n', '<leader>w', '<cmd>w<CR>', { desc = 'Save file' })
map('n', '<leader>W', '<cmd>wa<CR>', { desc = 'Save all files' })

-- Quick quit
map('n', '<leader>q', '<cmd>q<CR>', { desc = 'Quit' })
map('n', '<leader>Q', '<cmd>qa!<CR>', { desc = 'Force quit all' })

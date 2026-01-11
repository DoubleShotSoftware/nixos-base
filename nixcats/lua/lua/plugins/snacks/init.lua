-- nixcats/lua/plugins/snacks/init.lua
-- Snacks.nvim setup - dashboard, notifications, and utilities

local ok, Snacks = pcall(require, 'snacks')
if not ok then
  return
end

local dashboard_config = require('plugins.snacks.dashboard')

Snacks.setup({
  -- Core features
  bigfile = { enabled = true },
  notifier = { enabled = true, timeout = 3000 },
  quickfile = { enabled = true },
  words = { enabled = true },

  -- Picker (handles vim.ui.select)
  picker = { enabled = true },

  -- Git integration
  gitbrowse = { enabled = true },

  -- Dashboard
  dashboard = dashboard_config,

  -- Disabled for now (layer in later)
  statuscolumn = { enabled = false },
  lazygit = { enabled = false },
})

-- Snacks keymaps
local map = vim.keymap.set

-- Git
map('n', '<leader>gl', function()
  Snacks.git.blame_line()
end, { desc = 'Git blame line' })

-- Notifier
map('n', '<leader>un', function()
  Snacks.notifier.hide()
end, { desc = 'Dismiss notifications' })

map('n', '<leader>uN', function()
  Snacks.notifier.show_history()
end, { desc = 'Notification history' })

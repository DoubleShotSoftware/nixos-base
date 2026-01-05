-- nixcats/lua/plugins/snacks/init.lua
-- Snacks.nvim setup - dashboard, notifications, and utilities

local ok, Snacks = pcall(require, "snacks")
if not ok then
  return
end

local dashboard_config = require("plugins.snacks.dashboard")

Snacks.setup({
  -- Core features
  bigfile = { enabled = true },
  notifier = { enabled = true, timeout = 3000 },
  quickfile = { enabled = true },
  words = { enabled = true },

  -- UI replacements (replaces dressing.nvim)
  input = { enabled = true },
  picker = { enabled = true }, -- provides vim.ui.select

  -- Git integration
  gitbrowse = { enabled = true },

  -- Dashboard
  dashboard = dashboard_config,

  -- Disabled - using neo-tree instead
  explorer = { enabled = false },

  -- Disabled for now (layer in later)
  statuscolumn = { enabled = false },
  lazygit = { enabled = false },
  dim = {
    enabled = true,
    scope = {
      min_size = 5,
      max_size = 20,
      siblings = true,
    },
    animate = {
      enabled = vim.fn.has("nvim-0.10") == 1,
      easing = "outQuad",
      duration = {
        step = 20, -- ms per step
        total = 300, -- maximum duration
      },
    },
    -- what buffers to dim
    filter = function(buf)
      return vim.g.snacks_dim ~= false and vim.b[buf].snacks_dim ~= false and vim.bo[buf].buftype == ""
    end,
  },
})

-- Snacks keymaps
local map = vim.keymap.set

-- Git
map("n", "<leader>gl", function()
  Snacks.git.blame_line()
end, { desc = "Git blame line" })

-- Notifier
map("n", "<leader>un", function()
  Snacks.notifier.hide()
end, { desc = "Dismiss notifications" })

-- Ensure dashboard opens on startup
vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    -- Defer to ensure we run after other VimEnter autocmds
    vim.defer_fn(function()
      -- Only open if no arguments and buffer is empty/unnamed
      if vim.fn.argc(-1) == 0
        and vim.bo.buftype == ""
        and vim.api.nvim_buf_get_name(0) == ""
        and not vim.bo.modified
      then
        Snacks.dashboard()
      end
    end, 0)
  end,
})

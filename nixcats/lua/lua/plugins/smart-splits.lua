-- nixcats/lua/plugins/smart-splits.lua
-- Smart window navigation and resizing

local ok, smart_splits = pcall(require, 'smart-splits')
if not ok then
  return
end

smart_splits.setup({
  ignored_filetypes = { "nofile", "quickfix", "qf", "prompt" },
  ignored_buftypes = { "nofile" },
})

local map = vim.keymap.set

-- Window navigation
map('n', '<C-h>', function() smart_splits.move_cursor_left() end, { desc = 'Move to left split' })
map('n', '<C-j>', function() smart_splits.move_cursor_down() end, { desc = 'Move to below split' })
map('n', '<C-k>', function() smart_splits.move_cursor_up() end, { desc = 'Move to above split' })
map('n', '<C-l>', function() smart_splits.move_cursor_right() end, { desc = 'Move to right split' })

-- Window resizing
map('n', '<C-Up>', function() smart_splits.resize_up() end, { desc = 'Resize split up' })
map('n', '<C-Down>', function() smart_splits.resize_down() end, { desc = 'Resize split down' })
map('n', '<C-Left>', function() smart_splits.resize_left() end, { desc = 'Resize split left' })
map('n', '<C-Right>', function() smart_splits.resize_right() end, { desc = 'Resize split right' })

-- nixcats/lua/plugins/illuminate.lua
-- Reference highlighting with navigation

local ok, illuminate = pcall(require, 'illuminate')
if not ok then
  return
end

illuminate.configure({
  delay = 200,
  filetypes_denylist = { "dirbuf", "dirvish", "fugitive", "neo-tree", "TelescopePrompt" },
  large_file_overrides = {
    providers = { "lsp" },
  },
  min_count_to_highlight = 2,
  large_file_cutoff = 2000,
  should_enable = function(bufnr)
    if not vim.api.nvim_buf_is_valid(bufnr) then return false end
    local buftype = vim.bo[bufnr].buftype
    return buftype == "" or buftype == "help"
  end,
})

-- Keymaps for reference navigation
local map = vim.keymap.set

map('n', ']r', function()
  illuminate.goto_next_reference(false)
end, { desc = 'Next reference' })

map('n', '[r', function()
  illuminate.goto_prev_reference(false)
end, { desc = 'Previous reference' })

map('n', '<leader>ur', function()
  illuminate.toggle_buf()
end, { desc = 'Toggle reference highlighting (buffer)' })

map('n', '<leader>uR', function()
  illuminate.toggle()
end, { desc = 'Toggle reference highlighting (global)' })

-- nixcats/lua/plugins/tabline.lua
-- Tab bar configuration using tabby.nvim with theme-aware styling

local nixCats = require('nixCats')

-- Tab rename popup using nui.nvim
local Input = require('nui.input')
local event = require('nui.utils.autocmd').event

local function tab_rename_popup()
  local input = Input({
    position = '50%',
    size = { width = 40 },
    border = {
      style = 'rounded',
      text = { top = ' Rename Tab ', top_align = 'center' },
    },
    win_options = {
      winblend = 10,
      winhighlight = 'Normal:Normal,FloatBorder:FloatBorder',
    },
  }, {
    prompt = '> ',
    default_value = '',
    on_submit = function(value)
      vim.cmd('TabRename ' .. vim.fn.fnameescape(value))
    end,
  })

  input:mount()
  input:on(event.BufLeave, function()
    input:unmount()
  end)
end

vim.api.nvim_create_user_command('TabRenamePopup', tab_rename_popup, {})

-- Theme configuration (matching nixvim catppuccin mocha colors)
local theme = {
  fill = 'TabLineFill',
  head = { fg = '#8aadf4', bg = '#24273a', style = 'italic' },
  current_tab = { fg = '#1e2030', bg = '#8aadf4', style = 'italic' },
  tab = { fg = '#8aadf4', bg = '#24273a', style = 'italic' },
  win = { fg = '#1e2030', bg = '#8aadf4', style = 'italic' },
  tail = { fg = '#8aadf4', bg = '#24273a', style = 'italic' },
}

require('tabby.tabline').set(function(line)
  return {
    {
      { '  ', hl = theme.head },
      line.sep('', theme.head, theme.fill),
    },
    line.tabs().foreach(function(tab)
      local hl = tab.is_current() and theme.current_tab or theme.tab
      return {
        line.sep('', hl, theme.fill),
        tab.is_current() and '' or '',
        tab.number(),
        tab.name(),
        line.sep('', hl, theme.fill),
        hl = hl,
        margin = ' ',
      }
    end),
    line.spacer(),
    {
      line.sep('', theme.tail, theme.fill),
      { '  ', hl = theme.tail },
    },
    hl = theme.fill,
  }
end)

-- Tab keymaps
local map = vim.keymap.set
local opts = { silent = true }

-- Navigation
map('n', '[t', ':tabprevious<CR>', vim.tbl_extend('force', opts, { desc = 'Previous tab' }))
map('n', ']t', ':tabnext<CR>', vim.tbl_extend('force', opts, { desc = 'Next tab' }))

-- Tab management (leader T)
map('n', '<leader>Ta', ':$tabnew<CR>', vim.tbl_extend('force', opts, { desc = 'New tab' }))
map('n', '<leader>Tc', ':tabclose<CR>', vim.tbl_extend('force', opts, { desc = 'Close tab' }))
map('n', '<leader>To', ':tabonly<CR>', vim.tbl_extend('force', opts, { desc = 'Close other tabs' }))
map('n', '<leader>Tmp', ':-tabmove<CR>', vim.tbl_extend('force', opts, { desc = 'Move tab left' }))
map('n', '<leader>Tmn', ':+tabmove<CR>', vim.tbl_extend('force', opts, { desc = 'Move tab right' }))
map('n', '<leader>Tr', ':TabRenamePopup<CR>', vim.tbl_extend('force', opts, { desc = 'Rename tab' }))

-- Telescope tabs integration
map('n', '<leader>ft', ':Telescope telescope-tabs list_tabs<CR>', vim.tbl_extend('force', opts, { desc = 'Find tabs' }))

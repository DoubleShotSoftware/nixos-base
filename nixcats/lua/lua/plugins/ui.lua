-- nixcats/lua/plugins/ui.lua
-- UI plugin configurations

local nixCats = require('nixCats')

-- Build lualine_a section (conditionally add dotnet job indicator)
local lualine_a = { 'mode' }
if nixCats.cats["languages.dotnet"] then
  table.insert(lualine_a, require("easy-dotnet.ui-modules.jobs").lualine)
end

-- Lualine
require('lualine').setup({
  options = {
    theme = 'catppuccin',
    component_separators = { left = '', right = '' },
    section_separators = { left = '', right = '' },
    globalstatus = true,
  },
  sections = {
    lualine_a = lualine_a,
    lualine_b = { 'branch', 'diff', 'diagnostics' },
    lualine_c = { { 'filename', path = 1 } },
    lualine_x = { 'encoding', 'fileformat', 'filetype' },
    lualine_y = { 'progress' },
    lualine_z = { 'location' },
  },
})

-- Noice (notifications handled by snacks.notifier)
require('noice').setup({
  lsp = {
    override = {
      ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
      ['vim.lsp.util.stylize_markdown'] = true,
      ['cmp.entry.get_documentation'] = true,
    },
  },
  presets = {
    bottom_search = true,
    command_palette = true,
    long_message_to_split = true,
    inc_rename = false,
    lsp_doc_border = true,
  },
  -- Let snacks.notifier handle vim.notify()
  notify = {
    enabled = false,
  },
})

-- Neo-tree
require('neo-tree').setup({
  close_if_last_window = true,
  popup_border_style = 'rounded',
  enable_git_status = true,
  enable_diagnostics = true,
  filesystem = {
    filtered_items = {
      visible = false,
      hide_dotfiles = false,
      hide_gitignored = false,
      hide_by_name = {
        '.git',
        'node_modules',
      },
    },
    follow_current_file = {
      enabled = true,
    },
    use_libuv_file_watcher = true,
  },
  window = {
    position = 'left',
    width = 35,
  },
})

vim.keymap.set('n', '<leader>e', '<cmd>Neotree toggle<CR>', { desc = 'Toggle file explorer' })
vim.keymap.set('n', '<leader>o', '<cmd>Neotree focus<CR>', { desc = 'Focus file explorer' })

-- Which-key
require('which-key').setup({
  plugins = {
    marks = true,
    registers = true,
    spelling = { enabled = true, suggestions = 20 },
  },
  win = {
    border = 'rounded',
  },
})

-- Register key groups
require('which-key').add({
  { '<leader>b', group = 'Buffer' },
  { '<leader>f', group = 'Find' },
  { '<leader>g', group = 'Git' },
  { '<leader>l', group = 'LSP' },
  { '<leader>T', group = 'Tabs' },
  { '<leader>Tm', group = 'Move tab' },
  { '<leader>x', group = 'Trouble' },
  { '<leader>u', group = 'UI' },
})

-- Trouble
require('trouble').setup({
  auto_close = true,
  use_diagnostic_signs = true,
})

vim.keymap.set('n', '<leader>xx', '<cmd>Trouble diagnostics toggle<CR>', { desc = 'Diagnostics (Trouble)' })
vim.keymap.set('n', '<leader>xX', '<cmd>Trouble diagnostics toggle filter.buf=0<CR>', { desc = 'Buffer diagnostics' })
vim.keymap.set('n', '<leader>xs', '<cmd>Trouble symbols toggle<CR>', { desc = 'Symbols (Trouble)' })
vim.keymap.set('n', '<leader>xl', '<cmd>Trouble lsp toggle<CR>', { desc = 'LSP refs (Trouble)' })
vim.keymap.set('n', '<leader>xq', '<cmd>Trouble qflist toggle<CR>', { desc = 'Quickfix (Trouble)' })

-- Indent blankline
require('ibl').setup({
  indent = {
    char = '│',
  },
  scope = {
    enabled = true,
    show_start = true,
    show_end = false,
  },
  exclude = {
    filetypes = {
      'help',
      'dashboard',
      'neo-tree',
      'Trouble',
      'lazy',
      'mason',
      'notify',
      'toggleterm',
    },
  },
})

-- Todo comments
require('todo-comments').setup({})
vim.keymap.set('n', '<leader>xt', '<cmd>TodoTrouble<CR>', { desc = 'TODO (Trouble)' })
vim.keymap.set('n', '<leader>ft', '<cmd>TodoTelescope<CR>', { desc = 'Find TODOs' })

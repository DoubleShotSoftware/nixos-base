-- nixcats/lua/plugins/ui.lua
-- UI plugin configurations

local nixCats = require('nixCats')

-- Build lualine_a section (conditionally add dotnet job indicator)
local lualine_a = { 'mode' }
if nixCats.cats["languages.dotnet"] then
  table.insert(lualine_a, require("easy-dotnet.ui-modules.jobs").lualine)
end

-- Build lualine_c section
local lualine_c = { { 'filename', path = 1 } }

-- Dotnet solution indicator (lualine_z, far right)
local lualine_z = { 'location' }
if nixCats.cats["languages.dotnet"] then
  table.insert(lualine_z, {
    function()
      local ok, sln = pcall(require("easy-dotnet.current_solution").try_get_selected_solution)
      if ok and sln then
        return '\u{f0399} ' .. vim.fs.basename(sln)
      end
      return ''
    end,
    cond = function()
      return vim.bo.filetype == 'cs'
    end,
  })
end

-- Lualine
-- Track the active colorscheme (nixCats.extra.theme) rather than hardcoding a
-- theme: this build defaults to tokyonight, and naming a theme whose setup never
-- ran (e.g. catppuccin) makes lualine warn and fall back to 'auto'. Both
-- 'tokyonight' and 'catppuccin' are valid lualine theme names.
require('lualine').setup({
  options = {
    theme = (nixCats.extra and nixCats.extra.theme) or 'auto',
    component_separators = { left = '', right = '' },
    section_separators = { left = '', right = '' },
    globalstatus = true,
  },
  sections = {
    lualine_a = lualine_a,
    lualine_b = { 'branch', 'diff', 'diagnostics' },
    lualine_c = lualine_c,
    lualine_x = { 'encoding', 'fileformat', 'filetype' },
    lualine_y = { 'progress' },
    lualine_z = lualine_z,
  },
})

-- Noice (notifications handled by snacks.notifier)
-- LSP markdown override disabled: on Nvim 0.12 the archived nvim-treesitter
-- master branch injection queries crash during re-parse, and these hooks
-- fire on every LSP event (hover, signature help) amplifying the flood.
require('noice').setup({
  presets = {
    -- bottom_search routes / and ? to the bottom :cmdheight area; leaving
    -- it off keeps search in the centered command_palette popup, matching
    -- the rest of noice's surface (and the prior nixvim behavior).
    bottom_search = false,
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

  -- Source selector (tabs at top of neo-tree)
  source_selector = {
    winbar = true,
    content_layout = 'center',
    separator = '',
    sources = {
      { source = 'filesystem', display_name = ' Files' },
      { source = 'buffers', display_name = ' Bufs' },
      { source = 'git_status', display_name = ' Git' },
    },
  },

  -- Event handlers for better styling
  event_handlers = {
    {
      event = 'neo_tree_buffer_enter',
      handler = function()
        vim.opt_local.signcolumn = 'auto'
        vim.opt_local.foldcolumn = '0'
      end,
    },
  },

  -- Default component configs
  default_component_configs = {
    indent = {
      padding = 1,
      with_expanders = true,
    },
    git_status = {
      symbols = {
        added = '',
        modified = '',
        deleted = '',
        renamed = '',
        untracked = '',
        ignored = '',
        unstaged = '',
        staged = '',
        conflict = '',
      },
    },
  },

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
    hijack_netrw_behavior = 'open_current',
    use_libuv_file_watcher = true,
  },

  window = {
    position = 'left',
    width = 35,
    mappings = {
      ['<Space>'] = false,  -- Disable space toggle
      ['h'] = 'close_node',
      ['l'] = 'open',
      ['[b'] = 'prev_source',
      [']b'] = 'next_source',
    },
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
  { '<leader>lc', group = 'Call hierarchy' },
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

-- Main trouble keymaps under <leader>x
vim.keymap.set('n', '<leader>xx', '<cmd>Trouble diagnostics toggle<CR>', { desc = 'Diagnostics (Trouble)' })
vim.keymap.set('n', '<leader>xX', '<cmd>Trouble diagnostics toggle filter.buf=0<CR>', { desc = 'Buffer diagnostics' })
vim.keymap.set('n', '<leader>xs', '<cmd>Trouble symbols toggle<CR>', { desc = 'Symbols (Trouble)' })
vim.keymap.set('n', '<leader>xl', '<cmd>Trouble lsp toggle<CR>', { desc = 'LSP refs (Trouble)' })
vim.keymap.set('n', '<leader>xq', '<cmd>Trouble qflist toggle<CR>', { desc = 'Quickfix (Trouble)' })

-- LSP group shortcut (matches nixvim)
vim.keymap.set('n', '<leader>lx', '<cmd>Trouble diagnostics toggle focus=false filter.buf=0<CR>', { desc = 'Buffer diagnostics' })

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

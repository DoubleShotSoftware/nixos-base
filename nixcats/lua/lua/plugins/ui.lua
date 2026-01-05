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

-- Neo-tree (enhanced with AstroNvim-style features)
require('neo-tree').setup({
  close_if_last_window = true,
  popup_border_style = 'rounded',
  enable_git_status = true,
  enable_diagnostics = true,

  -- Event handlers for signcolumn/foldcolumn management
  event_handlers = {
    {
      event = 'neo_tree_buffer_enter',
      handler = function()
        vim.opt_local.signcolumn = 'auto'
        vim.opt_local.foldcolumn = '0'
      end,
    },
  },

  -- Custom commands (from AstroNvim)
  commands = {
    -- Focus first directory child item or open directory
    child_or_open = function(state)
      local node = state.tree:get_node()
      if node:has_children() then
        if not node:is_expanded() then
          state.commands.toggle_node(state)
        else
          if node.type == 'file' then
            state.commands.open(state)
          else
            require('neo-tree.ui.renderer').focus_node(state, node:get_child_ids()[1])
          end
        end
      else
        state.commands.open(state)
      end
    end,

    -- Focus parent directory or close directory
    parent_or_close = function(state)
      local node = state.tree:get_node()
      if node:has_children() and node:is_expanded() then
        state.commands.toggle_node(state)
      else
        require('neo-tree.ui.renderer').focus_node(state, node:get_parent_id())
      end
    end,

    -- Copy various path formats
    copy_selector = function(state)
      local node = state.tree:get_node()
      local filepath = node:get_id()
      local filename = node.name
      local modify = vim.fn.fnamemodify

      local vals = {
        ['BASENAME'] = modify(filename, ':r'),
        ['EXTENSION'] = modify(filename, ':e'),
        ['FILENAME'] = filename,
        ['PATH (CWD)'] = modify(filepath, ':.'),
        ['PATH (HOME)'] = modify(filepath, ':~'),
        ['PATH'] = filepath,
        ['URI'] = vim.uri_from_fname(filepath),
      }

      local options = vim.tbl_filter(function(val) return vals[val] ~= '' end, vim.tbl_keys(vals))
      if vim.tbl_isempty(options) then
        vim.notify('No values to copy', vim.log.levels.WARN)
        return
      end
      table.sort(options)
      vim.ui.select(options, {
        prompt = 'Choose to copy to clipboard:',
        format_item = function(item) return ('%s: %s'):format(item, vals[item]) end,
      }, function(choice)
        local result = vals[choice]
        if result then
          vim.notify(('Copied: `%s`'):format(result))
          vim.fn.setreg('+', result)
        end
      end)
    end,

    -- Find file in directory
    find_file_in_dir = function(state)
      local node = state.tree:get_node()
      local path = node.type == 'file' and node:get_parent_id() or node:get_id()
      require('telescope.builtin').find_files({ cwd = path })
    end,

    -- Grep in directory
    grep_in_dir = function(state)
      local node = state.tree:get_node()
      local path = node.type == 'file' and node:get_parent_id() or node:get_id()
      require('telescope.builtin').live_grep({ cwd = path })
    end,
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
    use_libuv_file_watcher = true,
    hijack_netrw_behavior = 'open_current',
  },

  window = {
    position = 'left',
    width = 35,
    mappings = {
      ['[b'] = 'prev_source',
      [']b'] = 'next_source',
      ['<Space>'] = 'none',  -- Disable default space behavior
      ['h'] = 'parent_or_close',
      ['l'] = 'child_or_open',
      ['Y'] = 'copy_selector',
      ['F'] = 'find_file_in_dir',
      ['W'] = 'grep_in_dir',
    },
    fuzzy_finder_mappings = {
      ['<C-j>'] = 'move_cursor_down',
      ['<C-k>'] = 'move_cursor_up',
    },
  },

  -- Source selector tabs
  source_selector = {
    winbar = true,
    separator = '',
    content_layout = 'center',
    sources = {
      { source = 'filesystem', display_name = ' Files' },
      { source = 'buffers', display_name = ' Bufs' },
      { source = 'git_status', display_name = ' Git' },
    },
  },
})

vim.keymap.set('n', '<leader>e', '<cmd>Neotree toggle<CR>', { desc = 'Toggle file explorer' })
vim.keymap.set('n', '<leader>o', '<cmd>Neotree focus<CR>', { desc = 'Focus file explorer' })

-- Auto-refresh neo-tree after lazygit closes
vim.api.nvim_create_autocmd('TermClose', {
  pattern = '*lazygit*',
  callback = function()
    local manager_ok, manager = pcall(require, 'neo-tree.sources.manager')
    if manager_ok then
      for _, source in ipairs({ 'filesystem', 'git_status' }) do
        local module = 'neo-tree.sources.' .. source
        if package.loaded[module] then
          manager.refresh(require(module).name)
        end
      end
    end
  end,
})

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
  { '<leader>lb', group = 'Language/Project' },
  { '<leader>T', group = 'Tabs' },
  { '<leader>Tm', group = 'Move tab' },
  { '<leader>u', group = 'UI' },
})

-- Trouble
require('trouble').setup({
  auto_close = true,
  use_diagnostic_signs = true,
})

-- Trouble keymaps (aligned with nixvim)
vim.keymap.set('n', '<leader>lx', '<cmd>Trouble diagnostics toggle focus=false filter.buf=0<CR>', { desc = 'Diagnostics' })
vim.keymap.set('n', '<leader>lo', '<cmd>Trouble symbols toggle focus=true<CR>', { desc = 'Outline (symbols)' })

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
vim.keymap.set('n', '<leader>ft', '<cmd>TodoTelescope<CR>', { desc = 'Find TODOs' })

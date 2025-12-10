-- nixcats/lua/plugins/telescope.lua
-- Telescope configuration

local telescope = require('telescope')
local builtin = require('telescope.builtin')

telescope.setup({
  defaults = {
    prompt_prefix = '   ',
    selection_caret = '  ',
    entry_prefix = '  ',
    sorting_strategy = 'ascending',
    layout_config = {
      horizontal = {
        prompt_position = 'top',
        preview_width = 0.55,
      },
      vertical = {
        mirror = false,
      },
      width = 0.87,
      height = 0.80,
      preview_cutoff = 120,
    },
    file_ignore_patterns = {
      'node_modules',
      '.git/',
      'target/',
      'bin/',
      'obj/',
    },
    mappings = {
      i = {
        ['<C-j>'] = 'move_selection_next',
        ['<C-k>'] = 'move_selection_previous',
        ['<C-q>'] = 'send_to_qflist',
      },
    },
  },
  pickers = {
    find_files = {
      hidden = true,
    },
    live_grep = {
      additional_args = function()
        return { '--hidden' }
      end,
    },
  },
  extensions = {
    fzf = {
      fuzzy = true,
      override_generic_sorter = true,
      override_file_sorter = true,
      case_mode = 'smart_case',
    },
  },
})

-- Load extensions
telescope.load_extension('fzf')
telescope.load_extension('telescope-tabs')

-- Keymaps
local map = vim.keymap.set
map('n', '<leader>ff', builtin.find_files, { desc = 'Find files' })
map('n', '<leader>fF', function()
  builtin.find_files({ hidden = true, no_ignore = true })
end, { desc = 'Find all files' })
map('n', '<leader>fg', builtin.live_grep, { desc = 'Live grep' })
map('n', '<leader>fw', builtin.grep_string, { desc = 'Find word under cursor' })
map('n', '<leader>fb', builtin.buffers, { desc = 'Find buffers' })
map('n', '<leader>fh', builtin.help_tags, { desc = 'Help tags' })
map('n', '<leader>fr', builtin.oldfiles, { desc = 'Recent files' })
map('n', '<leader>fR', builtin.registers, { desc = 'Find registers' })
map('n', '<leader>fc', builtin.commands, { desc = 'Commands' })
map('n', '<leader>fk', builtin.keymaps, { desc = 'Keymaps' })
map('n', '<leader>fd', builtin.diagnostics, { desc = 'Diagnostics' })
map('n', '<leader>fs', builtin.lsp_document_symbols, { desc = 'Document symbols' })
map('n', '<leader>fS', builtin.lsp_workspace_symbols, { desc = 'Workspace symbols' })
map('n', '<leader>/', builtin.current_buffer_fuzzy_find, { desc = 'Search in buffer' })
map('n', '<leader>f<CR>', builtin.resume, { desc = 'Resume search' })

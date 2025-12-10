-- nixcats/lua/plugins/git.lua
-- Git integration configuration

-- Gitsigns
require('gitsigns').setup({
  signs = {
    add = { text = '│' },
    change = { text = '│' },
    delete = { text = '_' },
    topdelete = { text = '‾' },
    changedelete = { text = '~' },
    untracked = { text = '┆' },
  },
  signcolumn = true,
  numhl = false,
  linehl = false,
  word_diff = false,
  watch_gitdir = {
    interval = 1000,
    follow_files = true,
  },
  attach_to_untracked = true,
  current_line_blame = false,
  current_line_blame_opts = {
    virt_text = true,
    virt_text_pos = 'eol',
    delay = 1000,
  },
  on_attach = function(bufnr)
    local gs = package.loaded.gitsigns
    local map = function(mode, l, r, desc)
      vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
    end

    -- Navigation
    map('n', ']h', gs.next_hunk, 'Next hunk')
    map('n', '[h', gs.prev_hunk, 'Previous hunk')

    -- Actions
    map('n', '<leader>gs', gs.stage_hunk, 'Stage hunk')
    map('n', '<leader>gr', gs.reset_hunk, 'Reset hunk')
    map('v', '<leader>gs', function() gs.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end, 'Stage hunk')
    map('v', '<leader>gr', function() gs.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end, 'Reset hunk')
    map('n', '<leader>gS', gs.stage_buffer, 'Stage buffer')
    map('n', '<leader>gu', gs.undo_stage_hunk, 'Undo stage hunk')
    map('n', '<leader>gR', gs.reset_buffer, 'Reset buffer')
    map('n', '<leader>gp', gs.preview_hunk, 'Preview hunk')
    map('n', '<leader>gb', function() gs.blame_line({ full = true }) end, 'Blame line')
    map('n', '<leader>gB', gs.toggle_current_line_blame, 'Toggle blame')
    map('n', '<leader>gd', gs.diffthis, 'Diff this')
    map('n', '<leader>gD', function() gs.diffthis('~') end, 'Diff this ~')
  end,
})

-- Diffview
require('diffview').setup({
  enhanced_diff_hl = true,
  view = {
    default = {
      layout = 'diff2_horizontal',
    },
    merge_tool = {
      layout = 'diff3_horizontal',
    },
  },
})

-- Diffview keymaps
vim.keymap.set('n', '<leader>gv', '<cmd>DiffviewOpen<CR>', { desc = 'Open diffview' })
vim.keymap.set('n', '<leader>gc', '<cmd>DiffviewClose<CR>', { desc = 'Close diffview' })
vim.keymap.set('n', '<leader>gh', '<cmd>DiffviewFileHistory %<CR>', { desc = 'File history' })

-- Lazygit
vim.keymap.set('n', '<leader>gg', '<cmd>LazyGit<CR>', { desc = 'LazyGit' })

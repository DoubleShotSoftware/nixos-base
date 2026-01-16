-- nixcats/lua/plugins/git.lua
-- Git integration configuration

local map = vim.keymap.set

-- =============================================================================
-- Gitsigns - hunks, blame, inline diff
-- =============================================================================
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
    local function bmap(mode, l, r, desc)
      vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
    end

    -- Navigation between hunks
    bmap('n', ']h', gs.next_hunk, 'Next hunk')
    bmap('n', '[h', gs.prev_hunk, 'Previous hunk')

    -- Staging (like git add, but per-hunk)
    bmap('n', '<leader>gs', gs.stage_hunk, 'Stage hunk')
    bmap('v', '<leader>gs', function() gs.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end, 'Stage hunk')
    bmap('n', '<leader>gS', gs.stage_buffer, 'Stage buffer')
    bmap('n', '<leader>gu', gs.undo_stage_hunk, 'Undo stage hunk')

    -- Reset (discard changes)
    bmap('n', '<leader>gr', gs.reset_hunk, 'Reset hunk')
    bmap('v', '<leader>gr', function() gs.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end, 'Reset hunk')
    bmap('n', '<leader>gR', gs.reset_buffer, 'Reset buffer')

    -- Preview hunk (see what changed before staging/resetting)
    bmap('n', '<leader>gp', gs.preview_hunk, 'Preview hunk')

    -- Blame
    bmap('n', '<leader>gB', function() gs.blame_line({ full = true }) end, 'Blame line (full)')
    bmap('n', '<leader>gb', gs.toggle_current_line_blame, 'Toggle inline blame')

    -- Quick diff (gitsigns)
    bmap('n', '<leader>gd', gs.diffthis, 'Diff vs HEAD')
  end,
})

-- =============================================================================
-- Diffview - side-by-side diff, file history, PR review
-- =============================================================================
require('diffview').setup({
  enhanced_diff_hl = true,
  view = {
    default = { layout = 'diff2_horizontal' },
    merge_tool = { layout = 'diff3_horizontal' },
  },
})

-- Diffview keymaps
map('n', '<leader>gv', '<cmd>DiffviewOpen<CR>', { desc = 'Diffview: open' })
map('n', '<leader>gq', '<cmd>DiffviewClose<CR>', { desc = 'Diffview: close' })
map('n', '<leader>gh', '<cmd>DiffviewFileHistory %<CR>', { desc = 'File history' })
map('n', '<leader>gH', '<cmd>DiffviewFileHistory<CR>', { desc = 'Repo history' })

-- Diff against specific ref (branch/commit)
map('n', '<leader>gD', function()
  local ref = vim.fn.input('Diff against ref: ', 'main')
  if ref ~= '' then
    vim.cmd('DiffviewOpen ' .. ref)
  end
end, { desc = 'Diff vs ref (prompt)' })

-- =============================================================================
-- CodeDiff - VSCode-style split diff
-- =============================================================================
map('n', '<leader>gc', '<cmd>CodeDiff<CR>', { desc = 'CodeDiff (split)' })

-- =============================================================================
-- DeltaView - inline diff using delta pager
-- =============================================================================
map('n', '<leader>gl', '<cmd>DeltaView<CR>', { desc = 'DeltaView (inline)' })
map('n', '<leader>gL', '<cmd>DeltaMenu<CR>', { desc = 'DeltaMenu (pick files)' })

-- DeltaView against specific ref
map('n', '<leader>gV', function()
  local ref = vim.fn.input('DeltaView against ref: ', 'main')
  if ref ~= '' then
    vim.cmd('DeltaView ' .. ref)
  end
end, { desc = 'DeltaView vs ref (prompt)' })

-- =============================================================================
-- Git Worktree
-- =============================================================================
local ok_wt, _ = pcall(require, 'git-worktree')
if ok_wt then
  local Hooks = require('git-worktree.hooks')

  -- Update buffer when switching worktrees
  Hooks.register(Hooks.type.SWITCH, Hooks.builtins.update_current_buffer_on_switch)

  -- Load telescope extension
  local ok_telescope, telescope = pcall(require, 'telescope')
  if ok_telescope then
    telescope.load_extension('git_worktree')
  end

  -- Worktree keymaps
  map('n', '<leader>gw', function()
    require('telescope').extensions.git_worktree.git_worktrees()
  end, { desc = 'Switch worktree' })

  map('n', '<leader>gW', function()
    require('telescope').extensions.git_worktree.create_git_worktree()
  end, { desc = 'Create worktree' })
end

-- =============================================================================
-- Telescope Git Pickers
-- =============================================================================
local ok_builtin, builtin = pcall(require, 'telescope.builtin')
if ok_builtin then
  -- Commits
  map('n', '<leader>gC', builtin.git_commits, { desc = 'Git commits (all)' })
  map('n', '<leader>gf', builtin.git_bcommits, { desc = 'File commits (this file)' })

  -- Branches
  map('n', '<leader>gt', builtin.git_branches, { desc = 'Git branches' })

  -- Status
  map('n', '<leader>gF', builtin.git_status, { desc = 'Git status (files)' })
end

-- =============================================================================
-- Find Deleted Files - search for files that were deleted in git history
-- =============================================================================
map('n', '<leader>gx', function()
  local pattern = vim.fn.input('Search deleted files (pattern): ', '')
  local cmd
  if pattern == '' then
    -- Show all deleted files
    cmd = "git log --diff-filter=D --name-only --pretty=format:'%h %s' | grep -v '^$'"
  else
    -- Search for specific pattern
    cmd = string.format("git log --all --full-history -- '**/*%s*' --pretty=format:'%%h %%s' --name-only | grep -v '^$'", pattern)
  end

  -- Use telescope to display results
  local ok_pickers, pickers = pcall(require, 'telescope.pickers')
  local ok_finders, finders = pcall(require, 'telescope.finders')
  local ok_conf, conf = pcall(require, 'telescope.config')
  local ok_actions, actions = pcall(require, 'telescope.actions')
  local ok_state, action_state = pcall(require, 'telescope.actions.state')

  if ok_pickers and ok_finders and ok_conf and ok_actions and ok_state then
    local results = vim.fn.systemlist(cmd)
    pickers.new({}, {
      prompt_title = 'Deleted Files',
      finder = finders.new_table({ results = results }),
      sorter = conf.values.generic_sorter({}),
      attach_mappings = function(prompt_bufnr, _)
        actions.select_default:replace(function()
          local selection = action_state.get_selected_entry()
          actions.close(prompt_bufnr)
          if selection then
            -- Extract commit hash if present
            local line = selection[1]
            local hash = line:match('^(%x+)')
            if hash then
              vim.cmd('DiffviewOpen ' .. hash .. '^..' .. hash)
            end
          end
        end)
        return true
      end,
    }):find()
  else
    -- Fallback: just show in quickfix
    vim.fn.setqflist({}, ' ', { title = 'Deleted Files', lines = vim.fn.systemlist(cmd) })
    vim.cmd('copen')
  end
end, { desc = 'Find deleted files' })

-- =============================================================================
-- LazyGit - full git TUI
-- =============================================================================
map('n', '<leader>gg', '<cmd>LazyGit<CR>', { desc = 'LazyGit' })

-- =============================================================================
-- Snacks Git Browse
-- =============================================================================
local ok_snacks, Snacks = pcall(require, 'snacks')
if ok_snacks and Snacks.gitbrowse then
  map('n', '<leader>go', function()
    Snacks.gitbrowse()
  end, { desc = 'Open in browser' })
end

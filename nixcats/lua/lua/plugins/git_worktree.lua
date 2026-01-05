-- nixcats/lua/plugins/git_worktree.lua
-- Git worktree management with telescope integration

local worktree_ok, _ = pcall(require, 'git-worktree')
if not worktree_ok then
  return
end

local Hooks = require('git-worktree.hooks')
Hooks.register(Hooks.type.SWITCH, Hooks.builtins.update_current_buffer_on_switch)

require('telescope').load_extension('git_worktree')

-- List/switch worktrees
vim.keymap.set('n', '<leader>gw', function()
  require('telescope').extensions.git_worktree.git_worktree()
end, { desc = 'Git worktrees' })

-- Create worktree
vim.keymap.set('n', '<leader>gW', function()
  require('telescope').extensions.git_worktree.create_git_worktree()
end, { desc = 'Create worktree' })

-- Set upstream branch (pick via telescope)
vim.keymap.set('n', '<leader>gU', function()
  require('telescope.builtin').git_branches({
    attach_mappings = function(_, map)
      local actions = require('telescope.actions')
      local action_state = require('telescope.actions.state')
      actions.select_default:replace(function(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        if selection then
          vim.fn.system('git branch --set-upstream-to=' .. selection.value)
          vim.notify('Upstream set to: ' .. selection.value)
        end
      end)
      return true
    end,
  })
end, { desc = 'Set upstream branch' })

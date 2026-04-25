-- nixcats/lua/plugins/folding.lua
-- nvim-ufo: LSP-aware folding with treesitter → indent fallback.
-- Requires foldlevel/foldlevelstart = 99 so ufo can render its virtual
-- fold text. Folds stay OPEN by default; use zM/zm to collapse manually.

local ok, ufo = pcall(require, 'ufo')
if not ok then return end

local function handle_fallback(bufnr, err, provider)
  if type(err) == 'string' and err:match('UfoFallbackException') then
    return ufo.getFolds(bufnr, provider)
  end
  return require('promise').reject(err)
end

ufo.setup({
  preview = {
    mappings = {
      scrollB = '<c-b>',
      scrollD = '<c-d>',
      scrollF = '<c-f>',
      scrollU = '<c-u>',
    },
  },
  provider_selector = function(_, filetype, buftype)
    if filetype == '' or buftype == 'nofile' then
      return 'indent'
    end
    return function(bufnr)
      return ufo.getFolds(bufnr, 'lsp')
        :catch(function(err) return handle_fallback(bufnr, err, 'treesitter') end)
        :catch(function(err) return handle_fallback(bufnr, err, 'indent') end)
    end
  end,
})

-- On first read of a buffer, collapse folds deeper than level 6. Guarded by
-- a buffer-local flag so re-edits, formats, and saves don't re-collapse.
local initial_fold_level = 6
vim.api.nvim_create_autocmd('BufReadPost', {
  callback = function(ev)
    if vim.b[ev.buf].ufo_initial_fold_done then return end
    vim.b[ev.buf].ufo_initial_fold_done = true
    vim.defer_fn(function()
      if vim.api.nvim_buf_is_valid(ev.buf) and vim.api.nvim_get_current_buf() == ev.buf then
        pcall(ufo.closeFoldsWith, initial_fold_level)
      end
    end, 100)
  end,
})

vim.keymap.set('n', 'zR', ufo.openAllFolds, { desc = 'Open all folds' })
vim.keymap.set('n', 'zM', ufo.closeAllFolds, { desc = 'Close all folds' })
vim.keymap.set('n', 'zr', ufo.openFoldsExceptKinds, { desc = 'Open folds except kinds' })
vim.keymap.set('n', 'zm', ufo.closeFoldsWith, { desc = 'Close folds (prompt level)' })
vim.keymap.set('n', 'zp', ufo.peekFoldedLinesUnderCursor, { desc = 'Peek fold' })

-- Quick depth presets: <leader>z[1-4] collapses to that depth.
for i = 1, 4 do
  vim.keymap.set('n', '<leader>z' .. i, function() ufo.closeFoldsWith(i) end,
    { desc = 'Close folds deeper than ' .. i })
end

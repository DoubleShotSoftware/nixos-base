-- nixcats/lua/plugins/folding.lua
-- nvim-ufo: LSP-aware folding with treesitter → indent fallback.
-- Requires foldlevel/foldlevelstart = 99 so ufo can render its virtual
-- fold text; we then close folds deeper than level 4 on BufRead.

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

-- Default fold depth: keep levels 0..4 open, collapse deeper.
local close_to_level = 4
vim.api.nvim_create_autocmd({ 'BufReadPost', 'FileType' }, {
  callback = function()
    vim.defer_fn(function()
      pcall(ufo.closeFoldsWith, close_to_level)
    end, 50)
  end,
})

vim.keymap.set('n', 'zR', ufo.openAllFolds, { desc = 'Open all folds' })
vim.keymap.set('n', 'zM', ufo.closeAllFolds, { desc = 'Close all folds' })
vim.keymap.set('n', 'zr', ufo.openFoldsExceptKinds, { desc = 'Open folds except kinds' })
vim.keymap.set('n', 'zm', ufo.closeFoldsWith, { desc = 'Close folds with level' })
vim.keymap.set('n', 'zp', ufo.peekFoldedLinesUnderCursor, { desc = 'Peek fold' })

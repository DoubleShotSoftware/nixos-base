-- nixcats/lua/plugins/ufo.lua
-- Advanced code folding with preview

local ok, ufo = pcall(require, 'ufo')
if not ok then
  return
end

-- Handler for fold provider fallback exceptions
local function handleFallbackException(bufnr, err, providerName)
  if type(err) == "string" and err:match("UfoFallbackException") then
    return ufo.getFolds(bufnr, providerName)
  else
    return require("promise").reject(err)
  end
end

ufo.setup({
  preview = {
    mappings = {
      scrollB = "<C-b>",
      scrollD = "<C-d>",
      scrollF = "<C-f>",
      scrollU = "<C-u>",
    },
  },
  -- Intelligent provider selection: LSP -> treesitter -> indent
  provider_selector = function(_, filetype, buftype)
    -- Use indent for empty filetypes or nofile buffers
    if filetype == "" or buftype == "nofile" then
      return "indent"
    end
    -- Try LSP first, fall back to treesitter, then indent
    return function(bufnr)
      return ufo.getFolds(bufnr, "lsp")
        :catch(function(err) return handleFallbackException(bufnr, err, "treesitter") end)
        :catch(function(err) return handleFallbackException(bufnr, err, "indent") end)
    end
  end,
})

-- Keymaps
vim.keymap.set('n', 'zR', ufo.openAllFolds, { desc = 'Open all folds' })
vim.keymap.set('n', 'zM', ufo.closeAllFolds, { desc = 'Close all folds' })
vim.keymap.set('n', 'zp', ufo.peekFoldedLinesUnderCursor, { desc = 'Peek fold' })

-- Set fold options for ufo
vim.o.foldcolumn = '1'
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true

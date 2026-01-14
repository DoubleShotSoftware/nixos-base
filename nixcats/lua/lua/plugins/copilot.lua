-- nixcats/lua/plugins/copilot.lua
-- GitHub Copilot configuration

local ok, copilot = pcall(require, 'copilot')
if not ok then
  vim.notify('copilot not found', vim.log.levels.WARN)
  return
end

copilot.setup({
  panel = {
    enabled = true,
    auto_refresh = false,
    keymap = {
      jump_prev = '[[',
      jump_next = ']]',
      accept = '<CR>',
      refresh = 'gr',
      open = '<M-CR>',
    },
    layout = {
      position = 'bottom',
      ratio = 0.4,
    },
  },
  suggestion = {
    enabled = true,
    auto_trigger = true,
    debounce = 75,
    keymap = {
      accept = '<M-l>',
      accept_word = false,
      accept_line = '<M-L>',
      next = '<M-]>',
      prev = '<M-[>',
      dismiss = '<C-]>',
    },
  },
  filetypes = {
    yaml = false,
    markdown = false,
    help = false,
    gitcommit = false,
    gitrebase = false,
    hgcommit = false,
    svn = false,
    cvs = false,
    -- Note: ['.'] = false would disable ALL filetypes not listed above
  },
})

-- Super Tab: accept copilot suggestion with Tab if visible
vim.keymap.set('i', '<Tab>', function()
  if require('copilot.suggestion').is_visible() then
    require('copilot.suggestion').accept()
  else
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Tab>', true, false, true), 'n', false)
  end
end, { desc = 'Super Tab' })

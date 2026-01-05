-- nixcats/lua/plugins/lint.lua
-- Linting with nvim-lint

local ok, lint = pcall(require, 'lint')
if not ok then
  return
end

-- Configure linters by filetype
lint.linters_by_ft = {
  markdown = { 'vale' },
  nix = { 'deadnix' },
  rust = { 'clippy' },
}

-- Auto-lint on save and text changes
vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
  callback = function()
    lint.try_lint()
  end,
})

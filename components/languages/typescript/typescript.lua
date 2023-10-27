local status_ok, _ = pcall(require, "lspconfig")
if not status_ok then
  return
end
local on_attach = require("lsp.handlers")
require('lspconfig')['tsserver'].setup({
  on_attach = on_attach.on_attach
})
require('lspconfig').eslint.setup({})
vim.api.nvim_command([[autocmd BufWritePre *.tsx,*.ts,*.jsx,*.js EslintFixAll]])

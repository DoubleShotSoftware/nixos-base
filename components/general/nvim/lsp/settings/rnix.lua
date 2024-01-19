local on_attach = require("lsp.handlers")
require('lspconfig').rnix.setup({
  on_attach=on_attach.on_attach
})
vim.api.nvim_command([[autocmd BufWritePre *.nix lua vim.lsp.buf.format()]])

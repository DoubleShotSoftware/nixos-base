local status_ok, _ = pcall(require, "lspconfig")
if not status_ok then
  return
end
local on_attach = require("lsp.handlers")
require('lspconfig')['pyright'].setup({
  on_attach = on_attach.on_attach
})

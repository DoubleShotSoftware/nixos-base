local status_ok, _ = pcall(require, "lspconfig")
if not status_ok then
  return
end
function setup()
  require('lspconfig')['bashls'].setup({
    on_attach = lsp_config.on_attach,
    capabilities = lsp_config.capabilities
  })
end

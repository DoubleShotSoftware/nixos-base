local status_ok, _ = pcall(require, "lspconfig")
if not status_ok then
	return
end
require('lspconfig')['terraform_lsp'].setup({
   on_attach=on_attach
})

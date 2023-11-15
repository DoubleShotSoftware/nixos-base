local status_ok, _ = pcall(require, "lspconfig")
local lsp_config = require("user.lsp.config_nvim_lspconfig")
if not status_ok then
	return
end
require("lspconfig")["bashls"].setup({
	on_attach = lsp_config.on_attach,
	capabilities = lsp_config.capabilities,
})

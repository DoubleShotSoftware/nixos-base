local status_ok, _ = pcall(require, "lspconfig")
if not status_ok then
	return
end
local lsp_handler = require("user.lsp.handlers")
require("lspconfig")["jsonls"].setup({
	on_attach = lsp_handler.on_attach,
	settings = {
		json = {
			schemas = require("schemastore").json.schemas(),
			validate = { enable = true },
		},
	},
})

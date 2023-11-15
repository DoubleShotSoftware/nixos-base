local lsp_config = require("user.lsp.config_nvim_lspconfig")
require("lspconfig").jsonls.setup({
	on_attach = lsp_config.on_attach,
	capabilities = lsp_config.capabilities,
	settings = {
		json = {
			schemas = require("schemastore").json.schemas(),
			validate = { enable = true },
		},
	},
})

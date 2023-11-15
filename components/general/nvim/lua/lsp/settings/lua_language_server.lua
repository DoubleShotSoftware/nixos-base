local lsp_config = require("user.lsp.config_nvim_lspconfig")
require("lspconfig")["lua_ls"].setup({
	on_attach = lsp_config.on_attach,
	capabilities = lsp_config.capabilities,
	settings = {
		Lua = {
			diagnostics = {
				globals = { "vim" },
			},
			workspace = {
				library = {
					[vim.fn.expand("$VIMRUNTIME/lua")] = true,
					[vim.fn.stdpath("config") .. "/lua"] = true,
				},
			},
			telemetry = {
				enable = false,
			},
		},
	},
})

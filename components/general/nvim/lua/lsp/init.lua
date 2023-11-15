local status_ok, _ = pcall(require, "lspconfig")
if not status_ok then
	return
end

local lsp_config = require("user.lsp.config_nvim_lspconfig")

require("fidget").setup({
	-- options
})

-- mason-lspconfig requires that these setup functions are called in this order
-- before setting up the servers.
require("mason").setup()
require("mason-lspconfig").setup()

-- Ensure the servers above are installed
local mason_lspconfig = require("mason-lspconfig")

mason_lspconfig.setup({})
mason_lspconfig.setup_handlers({
	function(server_name)
		require("lspconfig")[server_name].setup({
			capabilities = lsp_config.capabilities,
			on_attach = lsp_config.on_attach,
		})
	end,
})

require("user.lsp.settings").setup(lsp_config)
require("user.lsp.cmp")
require("user.lsp.trouble")

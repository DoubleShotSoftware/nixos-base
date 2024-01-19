local status_ok, _ = pcall(require, "lspconfig")
if not status_ok then
	return
end

local lsp_config = require("user.lsp.config_nvim_lspconfig")
require("user.lsp.mason")

require("fidget").setup({
	-- options
})
require("user.lsp.settings").setup(lsp_config)
require("user.lsp.trouble")

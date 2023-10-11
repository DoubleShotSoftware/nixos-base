local status_ok, _ = pcall(require, "lspconfig")
if not status_ok then
	return
end
require("lsp.handlers").setup()
require("lsp.settings.lua_language_server")
require("lsp.settings.null-ls")
require("lsp.settings.jsonls")
require("lsp.settings.yamlls")
require("lsp.settings.rnix")
require("lsp.settings.bashls")
require("lsp.config_nvim_lspconfig")
require("lsp.cmp")
require("lsp.trouble")

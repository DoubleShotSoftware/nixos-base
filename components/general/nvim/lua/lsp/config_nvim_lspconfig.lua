-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = require("user.lsp.on_attach")

local lsp_flags = {
	-- This is the default in Nvim 0.7+
	debounce_text_changes = 150,
}

local capabilities = vim.lsp.protocol.make_client_capabilities()

local M = {
	on_attach = on_attach,
	lsp_flags = lsp_flags,
	capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities),
}
return M

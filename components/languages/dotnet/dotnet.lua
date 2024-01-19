local mason_status_ok, mason_lspconfig = pcall(require, "mason-lspconfig")
if not mason_status_ok then
	vim.notify("Couldn't load Mason-LSP-Config" .. mason_lspconfig, "error")
	return
end

local status_ok, _ = pcall(require, "lspconfig")
if not status_ok then
	vim.notify("Couldn't load LSP-Config" .. lspconfig, "error")
	return
end

local lsp_handler = require("user.lsp.handlers")
if not status_ok then
	print("LSP Is not ok in omnisharp")
	return
end
local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())
local function on_attach(client, bufnr)
	-- https://github.com/williamboman/mason-lspconfig.nvim/issues/211
	-- Cause of E5248 Invalid Characters
	client.server_capabilities.semanticTokensProvider = nil
	return lsp_handler.on_attach(client, bufnr)
end

local config = {
	capabilities = capabilities,
	on_attach = on_attach,
	handlers = {
		["textDocument/definition"] = require("omnisharp_extended").handler,
	},
	enable_import_completion = true,
	organize_imports_on_format = true,
	enable_roslyn_analyzers = true,
}

require("lspconfig")["omnisharp"].setup(config)

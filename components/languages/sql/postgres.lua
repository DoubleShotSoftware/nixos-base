local status_ok, _ = pcall(require, "lspconfig")
local home_dir = os.getenv("HOME")
if not status_ok then
	vim.notify("Couldn't load LSP-Config" .. lspconfig, "error")
	return
end
local lsp_handler = require("user.lsp.handlers")
local config_path = home_dir .. "/.config/sqls.yaml"
print(config_path)
local postgresPaths = require("user.lsp.settings.postgrespths")
require("lspconfig")["sqls"].setup({
  cmd = {postgresPaths.SQLS, "-config", config_path}
  
})

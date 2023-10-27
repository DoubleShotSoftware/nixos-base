local status_ok, _ = pcall(require, "lspconfig")
if not status_ok then
  return
end
local on_attach = require("lsp.handlers")
local nvim_lsp = require('lspconfig')
require('lspconfig')['kotlin_language_server'].setup({
  on_attach = on_attach.on_attach,
  root_dir = nvim_lsp.util.root_pattern('settings.gradle.kts', 'settings.gradle', 'pom.xml')
})
require('lspconfig')['java_language_server'].setup({
  on_attach = on_attach.on_attach,
  root_dir = nvim_lsp.util.root_pattern('settings.gradle.kts', 'settings.gradle', 'pom.xml')
})

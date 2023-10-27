local status_ok, _ = pcall(require, "lspconfig")
if not status_ok then
  print("LSP Is not ok in omnisharp")
  return
end
local lsp_handler = require("lsp.handlers")
local capabilities = require('cmp_nvim_lsp')
    .default_capabilities(vim.lsp.protocol.make_client_capabilities())
local function on_attach(client, bufnr)
  -- https://github.com/williamboman/mason-lspconfig.nvim/issues/211
  -- Cause of E5248 Invalid Characters
  client.server_capabilities.semanticTokensProvider = nil
  return lsp_handler.on_attach(client, bufnr)
end
local omnisharp = string.format("%s/.bin/omnisharp.sh", os.getenv("HOME") or "~/")

local config = {
  capabilities = capabilities,
  on_attach = on_attach,
  handlers = {
    ["textDocument/definition"] = require('omnisharp_extended').handler,
  },
  cmd = { omnisharp },
}

require('lspconfig')['omnisharp'].setup(config)

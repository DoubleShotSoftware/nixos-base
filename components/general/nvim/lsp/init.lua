local status_ok, _ = pcall(require, "lspconfig")
if not status_ok then
  return
end

local lsp_config = require("lsp.config_nvim_lspconfig")

-- mason-lspconfig requires that these setup functions are called in this order
-- before setting up the servers.
require('mason').setup()
require('mason-lspconfig').setup()

-- Ensure the servers above are installed
local mason_lspconfig = require 'mason-lspconfig'

mason_lspconfig.setup {}
mason_lspconfig.setup_handlers {
  function(server_name)
    require('lspconfig')[server_name].setup {
      capabilities = lsp_config.capabilities,
      on_attach = lsp_config.on_attach,
    }
  end,
}

require("lsp.handlers").setup()
require("lsp.settings").setup(lsp_config)
require("lsp.cmp")
require("lsp.trouble")

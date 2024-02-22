local lsp_config = require("user.lsp.config_nvim_lspconfig")
  require('lspconfig')['nixd'].setup({
    on_attach=lsp_config.on_attach,
    capabilities=lsp_config.capabilities
  })

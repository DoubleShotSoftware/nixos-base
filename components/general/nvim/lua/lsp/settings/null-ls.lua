local lsp_config = require("user.lsp.config_nvim_lspconfig")
  require("null-ls").setup({
    on_attach = lsp_config.on_attach,
    capabilities = lsp_config.capabilities,
    sources = {
      require("null-ls").builtins.formatting.stylua,
      require("null-ls").builtins.diagnostics.eslint,
      require("null-ls").builtins.completion.spell,
    },
  })

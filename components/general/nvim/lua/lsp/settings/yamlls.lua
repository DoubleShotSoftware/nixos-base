local lsp_config = require("user.lsp.config_nvim_lspconfig")
require('lspconfig').yamlls.setup {
    on_attach = lsp_config.on_attach,
    capabilities = lsp_config.capabilities,
    settings = {
      yaml = {
        schemas = {
          ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
        },
      },
    }
  }

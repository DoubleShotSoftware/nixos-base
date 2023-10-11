local on_attach = require("lsp.handlers")
require('lspconfig')["lua_ls"].setup({
  on_attach = on_attach.on_attach,
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        library = {
          [vim.fn.expand("$VIMRUNTIME/lua")] = true,
          [vim.fn.stdpath("config") .. "/lua"] = true,
        },
      },
      telemetry = {
        enable = false,
      }
    }
  }
})

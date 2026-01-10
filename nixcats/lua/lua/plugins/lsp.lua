-- nixcats/lua/plugins/lsp.lua
-- LSP configuration using vim.lsp.config (nvim 0.11+)

local nixCats = require('nixCats')

-- Common capabilities
local capabilities = vim.lsp.protocol.make_client_capabilities()

-- Blink.cmp integration if available
local ok_blink, blink = pcall(require, 'blink.cmp')
if ok_blink then
  capabilities = blink.get_lsp_capabilities(capabilities)
end

-- Global LSP keymaps via LspAttach autocmd
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    local bufnr = ev.buf
    local client = vim.lsp.get_client_by_id(ev.data.client_id)

    local map = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
    end

    -- Navigation
    map('n', 'gd', vim.lsp.buf.definition, 'Go to definition')
    map('n', 'gD', vim.lsp.buf.declaration, 'Go to declaration')
    map('n', 'gi', vim.lsp.buf.implementation, 'Go to implementation')
    map('n', 'gr', vim.lsp.buf.references, 'Go to references')
    map('n', 'gy', vim.lsp.buf.type_definition, 'Go to type definition')

    -- Information
    map('n', 'K', vim.lsp.buf.hover, 'Hover documentation')
    map('n', 'gl', vim.lsp.buf.signature_help, 'Signature help')

    -- Actions
    map('n', '<leader>la', vim.lsp.buf.code_action, 'Code action')
    map('n', '<leader>lr', vim.lsp.buf.references, 'References')
    map('n', '<leader>lR', vim.lsp.buf.rename, 'Rename symbol')
    map('n', '<leader>lf', function() vim.lsp.buf.format({ async = true }) end, 'Format buffer')
    map('n', '<leader>li', '<cmd>checkhealth lsp<CR>', 'LSP info')
    map('n', '<leader>lo', vim.lsp.buf.document_symbol, 'Document symbols')

    -- Diagnostics
    map('n', '<leader>ld', vim.diagnostic.open_float, 'Line diagnostics')
    map('n', '[d', vim.diagnostic.goto_prev, 'Previous diagnostic')
    map('n', ']d', vim.diagnostic.goto_next, 'Next diagnostic')

    -- CodeLens
    map('n', '<leader>ll', vim.lsp.codelens.refresh, 'CodeLens refresh')
    map('n', '<leader>lL', vim.lsp.codelens.run, 'CodeLens run')

    -- Inlay hints (if supported)
    if client and client.server_capabilities.inlayHintProvider then
      vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
    end
  end,
})

-- Helper to check language categories
local function hasLang(lang)
  return nixCats.cats["languages." .. lang]
end

-- Servers to enable
local servers_to_enable = {}

-- Always enable lua_ls
vim.lsp.config.lua_ls = {
  capabilities = capabilities,
}
table.insert(servers_to_enable, 'lua_ls')

-- Nix language support
if hasLang('nix') then
  vim.lsp.config.nixd = {
    capabilities = capabilities,
    settings = {
      nixd = {
        formatting = {
          command = { 'alejandra' },
        },
      },
    },
  }
  table.insert(servers_to_enable, 'nixd')
end

-- Rust language support
if hasLang('rust') then
  -- rustaceanvim handles rust-analyzer setup
  vim.g.rustaceanvim = {
    server = {
      capabilities = capabilities,
    },
  }
end

-- Python language support
if hasLang('python') then
  vim.lsp.config.pyright = {
    capabilities = capabilities,
  }
  table.insert(servers_to_enable, 'pyright')
end

-- TypeScript/JavaScript language support
if hasLang('typescript') then
  vim.lsp.config.ts_ls = {
    capabilities = capabilities,
  }
  vim.lsp.config.eslint = {
    capabilities = capabilities,
  }
  table.insert(servers_to_enable, 'ts_ls')
  table.insert(servers_to_enable, 'eslint')
end

-- JSON language support
if hasLang('json') then
  local schemas = {}
  local ok_schema, schemastore = pcall(require, 'schemastore')
  if ok_schema then
    schemas = schemastore.json.schemas()
  end
  vim.lsp.config.jsonls = {
    capabilities = capabilities,
    settings = {
      json = {
        schemas = schemas,
        validate = { enable = true },
      },
    },
  }
  table.insert(servers_to_enable, 'jsonls')
end

-- SQL language support
if hasLang('sql') then
  vim.lsp.config.sqls = {
    capabilities = capabilities,
  }
  table.insert(servers_to_enable, 'sqls')
end

-- Markdown language support
if hasLang('markdown') then
  vim.lsp.config.marksman = {
    capabilities = capabilities,
  }
  table.insert(servers_to_enable, 'marksman')
end

-- Terraform/OpenTofu language support
if hasLang('terraform') then
  vim.lsp.config.terraformls = {
    capabilities = capabilities,
  }
  table.insert(servers_to_enable, 'terraformls')
end

-- AWS CloudFormation/SAM support (via yamlls with CFN schema)
if hasLang('aws') then
  vim.lsp.config.yamlls = {
    capabilities = capabilities,
    settings = {
      yaml = {
        schemas = {
          ["https://raw.githubusercontent.com/awslabs/goformation/master/schema/cloudformation.schema.json"] = {
            "*.cf.yaml",
            "*.cf.yml",
            "template.yaml",
            "template.yml",
            "*-template.yaml",
            "*-template.yml",
          },
        },
        customTags = {
          "!Ref",
          "!Sub",
          "!GetAtt",
          "!If",
          "!Equals",
          "!Not",
          "!And",
          "!Or",
          "!FindInMap",
          "!Base64",
          "!Join",
          "!Select",
          "!Split",
          "!ImportValue",
          "!Condition",
          "!GetAZs",
        },
      },
    },
  }
  table.insert(servers_to_enable, 'yamlls')
end

-- Enable all configured servers
vim.lsp.enable(servers_to_enable)

-- Fidget (LSP progress)
require('fidget').setup({})

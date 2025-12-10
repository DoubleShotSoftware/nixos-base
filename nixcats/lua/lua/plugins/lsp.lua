-- nixcats/lua/plugins/lsp.lua
-- LSP configuration with nixCats category support

local nixCats = require('nixCats')
local lspconfig = require('lspconfig')

-- LSP keymaps (set on attach)
local on_attach = function(client, bufnr)
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
  map('n', '<leader>lr', vim.lsp.buf.rename, 'Rename symbol')
  map('n', '<leader>lf', function() vim.lsp.buf.format({ async = true }) end, 'Format buffer')
  map('n', '<leader>li', '<cmd>LspInfo<CR>', 'LSP info')

  -- Diagnostics
  map('n', '<leader>ld', vim.diagnostic.open_float, 'Line diagnostics')
  map('n', '[d', vim.diagnostic.goto_prev, 'Previous diagnostic')
  map('n', ']d', vim.diagnostic.goto_next, 'Next diagnostic')

  -- CodeLens
  map('n', '<leader>ll', vim.lsp.codelens.refresh, 'CodeLens refresh')
  map('n', '<leader>lL', vim.lsp.codelens.run, 'CodeLens run')

  -- Inlay hints (if supported)
  if client.server_capabilities.inlayHintProvider then
    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
  end
end

-- Common capabilities
local capabilities = vim.lsp.protocol.make_client_capabilities()

-- Blink.cmp integration if available
local ok, blink = pcall(require, 'blink.cmp')
if ok then
  capabilities = blink.get_lsp_capabilities(capabilities)
end

-- Default LSP config
local default_config = {
  on_attach = on_attach,
  capabilities = capabilities,
}

-- Always-enabled servers
local base_servers = {
  'lua_ls',
}

-- Configure base servers
for _, server in ipairs(base_servers) do
  lspconfig[server].setup(default_config)
end

-- Helper to check language categories (flat keys with dots)
local function hasLang(lang)
  return nixCats.cats["languages." .. lang]
end

-- Nix language support
if hasLang('nix') then
  lspconfig.nixd.setup(vim.tbl_extend('force', default_config, {
    settings = {
      nixd = {
        formatting = {
          command = { 'alejandra' },
        },
      },
    },
  }))
end

-- .NET/C# language support is in plugins/dotnet.lua (roslyn.nvim + easy-dotnet)

-- Rust language support
if hasLang('rust') then
  -- rustaceanvim handles rust-analyzer setup
  vim.g.rustaceanvim = {
    server = {
      on_attach = on_attach,
      capabilities = capabilities,
    },
  }
end

-- Python language support
if hasLang('python') then
  lspconfig.pyright.setup(default_config)
end

-- TypeScript/JavaScript language support
if hasLang('typescript') then
  lspconfig.ts_ls.setup(default_config)
  lspconfig.eslint.setup(default_config)
end

-- JSON language support
if hasLang('json') then
  lspconfig.jsonls.setup(vim.tbl_extend('force', default_config, {
    settings = {
      json = {
        schemas = require('schemastore').json.schemas(),
        validate = { enable = true },
      },
    },
  }))
end

-- SQL language support
if hasLang('sql') then
  lspconfig.sqls.setup(default_config)
end

-- Markdown language support
if hasLang('markdown') then
  lspconfig.marksman.setup(default_config)
end

-- Terraform/OpenTofu language support
if hasLang('terraform') then
  lspconfig.terraformls.setup(default_config)
end

-- AWS CloudFormation/SAM support (via yamlls with CFN schema)
if hasLang('aws') then
  lspconfig.yamlls.setup(vim.tbl_extend('force', default_config, {
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
  }))
end

-- Fidget (LSP progress)
require('fidget').setup({})

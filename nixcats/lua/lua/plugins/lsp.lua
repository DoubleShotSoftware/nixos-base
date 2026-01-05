-- nixcats/lua/plugins/lsp.lua
-- LSP configuration with nixCats category support
-- Uses vim.lsp.config (Neovim 0.11+)

local nixCats = require('nixCats')

-- Common capabilities
local capabilities = vim.lsp.protocol.make_client_capabilities()

-- Blink.cmp integration if available
local ok, blink = pcall(require, 'blink.cmp')
if ok then
  capabilities = blink.get_lsp_capabilities(capabilities)
end

-- LSP keymaps (set via LspAttach autocmd)
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

    -- Actions (use Telescope for searchable UI where available)
    map('n', '<leader>la', vim.lsp.buf.code_action, 'Code action')
    map('n', '<leader>lR', vim.lsp.buf.rename, 'Rename symbol')
    map('n', '<leader>lr', function() require('telescope.builtin').lsp_references() end, 'References')
    map('n', '<leader>li', '<cmd>LspInfo<CR>', 'LSP info')
    -- Format keymap is in plugins/conform.lua

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

      -- Refresh inlay hints after text changes to clear ghost text
      vim.api.nvim_create_autocmd({ 'InsertLeave', 'TextChanged' }, {
        buffer = bufnr,
        callback = function()
          if vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }) then
            vim.lsp.inlay_hint.enable(false, { bufnr = bufnr })
            vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
          end
        end,
      })
    end
  end,
})

-- Helper to check language categories
local function hasLang(lang)
  return nixCats.cats["languages." .. lang]
end

-- Servers to enable
local servers = {}

-- Always enable lua_ls
table.insert(servers, 'lua_ls')
vim.lsp.config.lua_ls = {
  capabilities = capabilities,
}

-- Nix language support
if hasLang('nix') then
  table.insert(servers, 'nixd')
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
end

-- .NET/C# language support is handled by easy-dotnet plugin

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
  table.insert(servers, 'pyright')
  vim.lsp.config.pyright = {
    capabilities = capabilities,
  }
end

-- TypeScript/JavaScript language support
if hasLang('typescript') then
  table.insert(servers, 'ts_ls')
  table.insert(servers, 'eslint')
  vim.lsp.config.ts_ls = {
    capabilities = capabilities,
  }
  vim.lsp.config.eslint = {
    capabilities = capabilities,
  }
end

-- JSON language support
if hasLang('json') then
  table.insert(servers, 'jsonls')
  vim.lsp.config.jsonls = {
    capabilities = capabilities,
    settings = {
      json = {
        schemas = require('schemastore').json.schemas(),
        validate = { enable = true },
      },
    },
  }
end

-- SQL language support
if hasLang('sql') then
  table.insert(servers, 'sqls')
  vim.lsp.config.sqls = {
    capabilities = capabilities,
  }
end

-- Markdown language support
if hasLang('markdown') then
  table.insert(servers, 'marksman')
  vim.lsp.config.marksman = {
    capabilities = capabilities,
  }
end

-- Terraform/OpenTofu language support
if hasLang('terraform') then
  table.insert(servers, 'terraformls')
  vim.lsp.config.terraformls = {
    capabilities = capabilities,
  }
end

-- AWS CloudFormation/SAM support (via yamlls with CFN schema)
if hasLang('aws') then
  table.insert(servers, 'yamlls')
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
end

-- Kotlin language support (JetBrains kotlin-lsp)
if hasLang('kotlin') then
  table.insert(servers, 'kotlin_language_server')
  vim.lsp.config.kotlin_language_server = {
    capabilities = capabilities,
    cmd = { 'kotlin-lsp' },
  }
end

-- Scala language support (metals)
if hasLang('scala') then
  -- nvim-metals handles metals setup
  local metals_ok, metals = pcall(require, 'metals')
  if metals_ok then
    local metals_config = metals.bare_config()
    metals_config.capabilities = capabilities
    metals_config.init_options.statusBarProvider = 'on'

    vim.api.nvim_create_autocmd('FileType', {
      pattern = { 'scala', 'sbt', 'java' },
      callback = function()
        metals.initialize_or_attach(metals_config)
      end,
    })
  end
end

-- Bash/Shell language support
if hasLang('bash') then
  table.insert(servers, 'bashls')
  vim.lsp.config.bashls = {
    capabilities = capabilities,
  }
end

-- Docker language support
if hasLang('docker') then
  table.insert(servers, 'dockerls')
  table.insert(servers, 'docker_compose_language_service')
  vim.lsp.config.dockerls = {
    capabilities = capabilities,
  }
  vim.lsp.config.docker_compose_language_service = {
    capabilities = capabilities,
  }
end

-- Enable all configured servers
vim.lsp.enable(servers)

-- Fidget (LSP progress)
require('fidget').setup({})

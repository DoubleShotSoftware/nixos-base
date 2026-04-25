-- nixcats/lua/plugins/lsp.lua
-- LSP configuration using vim.lsp.config (nvim 0.11+)

-- Register compound filetypes that lspconfig server definitions reference
vim.filetype.add({
  filename = {
    ['.gitlab-ci.yml'] = 'yaml.gitlab',
    ['.gitlab-ci.yaml'] = 'yaml.gitlab',
  },
  pattern = {
    ['docker%-compose[^/]*%.ya?ml'] = 'yaml.docker-compose',
    ['.*%.tfvars'] = 'terraform-vars',
  },
})

local nixCats = require('nixCats')

local kotlin_attach_log = vim.fn.stdpath('state') .. '/kotlin-lsp.attach.log'

local function kotlin_log(line)
  vim.fn.mkdir(vim.fn.fnamemodify(kotlin_attach_log, ':h'), 'p')
  local fd = io.open(kotlin_attach_log, 'a')
  if not fd then
    return
  end
  fd:write(os.date('%Y-%m-%d %H:%M:%S'), ' ', line, '\n')
  fd:close()
end

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
    -- Note: <leader>lf is handled by conform in formatting.lua
    map('n', '<leader>li', '<cmd>checkhealth lsp<CR>', 'LSP info')
    -- Note: <leader>lo is handled by lspsaga outline below

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

    if client and client.name == 'kotlin_lsp' then
      kotlin_log(
        string.format(
          'LspAttach buf=%d file=%s root=%s',
          bufnr,
          vim.api.nvim_buf_get_name(bufnr),
          client.config.root_dir or '<nil>'
        )
      )
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

-- Kotlin language support
if hasLang('kotlin') then
  local kotlin_lsp = nixCats('extra.kotlinLspBinary') or 'kotlin-lsp'
  local kotlin_state_dir = vim.fn.stdpath('state') .. '/kotlin-lsp'
  local kotlin_err_log = kotlin_state_dir .. '.err'

  local function kotlin_cmd(dispatchers, config)
    local root = (config and config.root_dir) or vim.loop.cwd() or vim.fn.getcwd()
    local system_path = kotlin_state_dir .. '/' .. vim.fn.sha256(root)
    vim.fn.mkdir(system_path, 'p')

    local shell_cmd = string.format(
      'exec %s --stdio --system-path %s 2>> %s',
      vim.fn.shellescape(kotlin_lsp),
      vim.fn.shellescape(system_path),
      vim.fn.shellescape(kotlin_err_log)
    )

    return vim.lsp.rpc.start({ 'sh', '-c', shell_cmd }, dispatchers, {
      cwd = root,
    })
  end

  vim.lsp.config.kotlin_lsp = {
    capabilities = capabilities,
    cmd = kotlin_cmd,
    filetypes = { 'kotlin' },
    root_markers = {
      'settings.gradle.kts',
      'settings.gradle',
      'build.gradle.kts',
      'build.gradle',
      'pom.xml',
      '.git',
    },
    single_file_support = false,
  }
  table.insert(servers_to_enable, 'kotlin_lsp')

  vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup('KotlinLspDebug', { clear = true }),
    pattern = 'kotlin',
    callback = function(ev)
      kotlin_log(
        string.format(
          'FileType buf=%d file=%s ft=%s',
          ev.buf,
          vim.api.nvim_buf_get_name(ev.buf),
          vim.bo[ev.buf].filetype
        )
      )
    end,
  })
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

-- =============================================================================
-- LSPSaga - enhanced LSP UI
-- =============================================================================
require('lspsaga').setup({
  -- Breadcrumbs (symbol path in winbar)
  symbol_in_winbar = {
    enable = true,
    separator = '  ',
    hide_keyword = true,
    show_file = true,
    folder_level = 2,
  },

  -- Outline (symbol tree)
  outline = {
    win_position = 'right',
    win_width = 40,
    auto_preview = false,
    detail = true,
    auto_close = true,
    close_after_jump = false,
    layout = 'normal',  -- normal or float
    keys = {
      toggle_or_jump = '<CR>',
      quit = 'q',
      jump = 'e',
    },
  },

  -- Code action lightbulb
  lightbulb = {
    enable = true,
    sign = true,
    virtual_text = false,
  },

  -- Finder (references/definitions)
  finder = {
    max_height = 0.5,
    left_width = 0.3,
    right_width = 0.5,
    default = 'ref+imp',
    keys = {
      toggle_or_open = '<CR>',
      vsplit = 'v',
      split = 's',
      quit = 'q',
    },
  },

  -- UI settings
  ui = {
    border = 'rounded',
    title = true,
    winblend = 0,
    expand = '',
    collapse = '',
    code_action = '💡',
    actionfix = ' ',
    imp_sign = '󰳛 ',
  },
})

-- LSPSaga keymaps
local map = vim.keymap.set

-- Outline (symbol tree) - <leader>lo
map('n', '<leader>lo', '<cmd>Lspsaga outline<CR>', { desc = 'LSP outline' })

-- Enhanced hover and diagnostics
map('n', '<leader>lk', '<cmd>Lspsaga hover_doc<CR>', { desc = 'Hover doc (saga)' })
map('n', '<leader>lD', '<cmd>Lspsaga show_line_diagnostics<CR>', { desc = 'Line diagnostics (saga)' })

-- Finder (references + implementations)
map('n', '<leader>lF', '<cmd>Lspsaga finder<CR>', { desc = 'LSP finder' })

-- Peek definition (without jumping)
map('n', '<leader>lp', '<cmd>Lspsaga peek_definition<CR>', { desc = 'Peek definition' })
map('n', '<leader>lP', '<cmd>Lspsaga peek_type_definition<CR>', { desc = 'Peek type definition' })

-- Call hierarchy
map('n', '<leader>lci', '<cmd>Lspsaga incoming_calls<CR>', { desc = 'Incoming calls' })
map('n', '<leader>lco', '<cmd>Lspsaga outgoing_calls<CR>', { desc = 'Outgoing calls' })

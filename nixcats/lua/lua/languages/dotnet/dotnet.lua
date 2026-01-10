-- nixcats/lua/lua/languages/dotnet/dotnet.lua
-- .NET development setup using easy-dotnet

local nixCats = require('nixCats')

-- Only load if dotnet category is enabled
if not nixCats.cats["languages.dotnet"] then
  return
end

-- Load LSP settings for Roslyn
local lsp_settings = require('lsp.easy_dotnet')

-- Get shared on_attach from lsp.lua pattern
local function on_attach(client, bufnr)
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
local ok_blink, blink = pcall(require, 'blink.cmp')
if ok_blink then
  capabilities = blink.get_lsp_capabilities(capabilities)
end

-- Pre-configure vim.lsp.config for easy_dotnet BEFORE setup
-- easy-dotnet merges capabilities from existing vim.lsp.config["easy_dotnet"]
vim.lsp.config.easy_dotnet = {
  capabilities = capabilities,
}

-- Set up LspAttach autocmd for easy_dotnet (easy-dotnet has its own on_attach we can't override)
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('EasyDotnetLspAttach', { clear = true }),
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client or client.name ~= 'easy_dotnet' then
      return
    end
    -- Apply our on_attach for easy_dotnet client
    on_attach(client, ev.buf)
  end,
})

-- Easy-dotnet setup (includes built-in Roslyn LSP)
require("easy-dotnet").setup({
  -- LSP configuration - settings go inside config.settings
  lsp = {
    enabled = true,
    roslynator_enabled = true,
    -- Settings must be inside config.settings (see roslyn/lsp.lua:330)
    config = {
      settings = lsp_settings.settings,
    },
  },

  -- Zero-config debugging with bundled NetCoreDbg
  debugger = {
    auto_register_dap = true,
    apply_value_converters = true,
  },

  -- Test runner with buffer execution
  test_runner = {
    viewmode = "float",
    enable_buffer_test_execution = true,
    noBuild = true,
  },

  -- Keep telescope
  picker = "telescope",

  -- Disable server features that might cause issues
  server = {
    use_visual_studio = false,
  },

  -- Terminal configuration for build output
  terminal = function(path, action, args, ctx)
    args = args or ""
    local commands = {
      run = function() return string.format("%s %s", ctx.cmd, args) end,
      test = function() return string.format("%s %s", ctx.cmd, args) end,
      restore = function() return string.format("%s %s", ctx.cmd, args) end,
      build = function() return string.format("%s %s", ctx.cmd, args) end,
      watch = function() return string.format("dotnet watch --project %s %s", path, args) end,
    }
    local command = commands[action]()
    vim.cmd("vsplit")
    vim.cmd("term " .. command)
  end,

  -- Other settings
  auto_bootstrap_namespace = { enabled = false },
})

-- Keybindings for dotnet files
local function setup_dotnet_keymaps()
  local opts = { buffer = true }
  -- Dotnet commands under <leader>lb
  vim.keymap.set("n", "<leader>lbe", "<cmd>Dotnet<CR>", vim.tbl_extend("force", opts, { desc = "Dotnet commands" }))
  vim.keymap.set("n", "<leader>lbb", "<cmd>Dotnet build quickfix<CR>", vim.tbl_extend("force", opts, { desc = "Build (quickfix)" }))
  vim.keymap.set("n", "<leader>lbr", "<cmd>Dotnet restore<CR>", vim.tbl_extend("force", opts, { desc = "Restore" }))
  vim.keymap.set("n", "<leader>lbc", "<cmd>Dotnet clean<CR>", vim.tbl_extend("force", opts, { desc = "Clean" }))
  vim.keymap.set("n", "<leader>lbt", "<cmd>Dotnet testrunner<CR>", vim.tbl_extend("force", opts, { desc = "Test runner" }))
  vim.keymap.set("n", "<leader>lbd", "<cmd>Dotnet debug<CR>", vim.tbl_extend("force", opts, { desc = "Debug" }))
  vim.keymap.set("n", "<leader>lbf", "<cmd>split | terminal dotnet format<CR>", vim.tbl_extend("force", opts, { desc = "Dotnet format" }))
  -- Buffer format with <leader>bf (matches nixvim)
  vim.keymap.set("n", "<leader>bf", function() vim.lsp.buf.format({ async = true }) end, vim.tbl_extend("force", opts, { desc = "Format buffer" }))
end

-- Set up keymaps for C# and project files
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "cs", "csproj", "fsproj", "sln" },
  callback = setup_dotnet_keymaps,
})

-- Ensure csproj/fsproj/sln are recognized as xml for treesitter
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "*.csproj", "*.fsproj", "*.props", "*.targets" },
  callback = function()
    vim.bo.filetype = "xml"
    setup_dotnet_keymaps()
  end,
})

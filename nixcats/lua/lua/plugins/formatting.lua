-- nixcats/lua/plugins/formatting.lua
-- Conform.nvim formatting with LSP fallback

local ok, conform = pcall(require, 'conform')
if not ok then
  vim.notify('conform.nvim not found', vim.log.levels.WARN)
  return
end

local nixCats = require('nixCats')

-- Helper to check language categories
local function hasLang(lang)
  return nixCats.cats["languages." .. lang]
end

-- Build formatters_by_ft based on enabled languages
local formatters_by_ft = {
  -- Always available
  lua = { 'stylua' },
}

-- Nix
if hasLang('nix') then
  formatters_by_ft.nix = { 'alejandra' }
end

-- .NET/C# (csharpier only, no LSP fallback)
if hasLang('dotnet') then
  formatters_by_ft.cs = { 'csharpier' }
end

-- TypeScript/JavaScript
if hasLang('typescript') then
  formatters_by_ft.javascript = { 'prettier' }
  formatters_by_ft.javascriptreact = { 'prettier' }
  formatters_by_ft.typescript = { 'prettier' }
  formatters_by_ft.typescriptreact = { 'prettier' }
  formatters_by_ft.vue = { 'prettier' }
  formatters_by_ft.css = { 'prettier' }
  formatters_by_ft.scss = { 'prettier' }
  formatters_by_ft.html = { 'prettier' }
end

-- Python
if hasLang('python') then
  formatters_by_ft.python = { 'black' }
end

-- Rust (rustfmt via rust-analyzer, but can add here)
if hasLang('rust') then
  formatters_by_ft.rust = { 'rustfmt' }
end

-- JSON
if hasLang('json') then
  formatters_by_ft.json = { 'prettier' }
  formatters_by_ft.jsonc = { 'prettier' }
end

-- Markdown
if hasLang('markdown') then
  formatters_by_ft.markdown = { 'prettier' }
end

-- SQL
if hasLang('sql') then
  formatters_by_ft.sql = { 'pg_format' }
end

-- Terraform
if hasLang('terraform') then
  formatters_by_ft.terraform = { 'terraform_fmt' }
  formatters_by_ft.tf = { 'terraform_fmt' }
  formatters_by_ft.hcl = { 'terraform_fmt' }
end

-- Custom formatter overrides
local formatters = {}

-- Configure csharpier with nix store path if available
local csharpierPath = nixCats('csharpierPath')
if csharpierPath then
  formatters.csharpier = {
    command = csharpierPath,
    args = { '--write-stdout' },
    stdin = true,
  }
end

conform.setup({
  formatters_by_ft = formatters_by_ft,

  -- LSP fallback for filetypes without explicit formatter
  default_format_opts = {
    lsp_format = 'fallback',
  },

  -- Log to help debug formatting issues
  log_level = vim.log.levels.DEBUG,

  -- Notify on format errors
  notify_on_error = true,
  notify_no_formatters = true,

  -- Custom formatter configs
  formatters = formatters,
})

-- Keymaps
vim.keymap.set({ 'n', 'v' }, '<leader>bf', function()
  conform.format({
    async = true,
    lsp_format = 'never',  -- Use configured formatters only, no LSP
  })
end, { desc = 'Format buffer (conform)' })

-- <leader>lf for LSP-only format (when you explicitly want LSP)
vim.keymap.set('n', '<leader>lf', function()
  vim.lsp.buf.format({ async = true })
end, { desc = 'Format buffer (LSP)' })

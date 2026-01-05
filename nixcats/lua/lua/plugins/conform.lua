-- nixcats/lua/plugins/conform.lua
-- Formatter configuration with LSP fallback
-- Uses nixCats categories to enable language-specific formatters

local nixCats = require('nixCats')

-- Helper to check language categories
local function hasLang(lang)
  return nixCats.cats["languages." .. lang]
end

-- Build formatters_by_ft dynamically based on enabled languages
local formatters_by_ft = {
  -- Fallback to LSP for unconfigured filetypes
  ['_'] = { lsp_format = 'fallback' },
      lua = { "stylua" },
}

-- Nix (always enabled as base)
if hasLang('nix') then
  formatters_by_ft.nix = { 'alejandra' }
end

-- C#/.NET
if hasLang('dotnet') then
  formatters_by_ft.cs = { 'csharpier' }
end

-- TypeScript/JavaScript
if hasLang('typescript') then
  formatters_by_ft.javascript = { 'prettierd', 'prettier', stop_after_first = true }
  formatters_by_ft.typescript = { 'prettierd', 'prettier', stop_after_first = true }
  formatters_by_ft.javascriptreact = { 'prettierd', 'prettier', stop_after_first = true }
  formatters_by_ft.typescriptreact = { 'prettierd', 'prettier', stop_after_first = true }
end

-- JSON
if hasLang('json') then
  formatters_by_ft.json = { 'prettierd', 'prettier', stop_after_first = true }
  formatters_by_ft.jsonc = { 'prettierd', 'prettier', stop_after_first = true }
end

-- SQL
if hasLang('sql') then
  formatters_by_ft.sql = { 'pg_format' }
end

-- Python
if hasLang('python') then
  formatters_by_ft.python = { 'ruff_format', 'black', stop_after_first = true }
end

-- Rust (prefer LSP/rustfmt)
if hasLang('rust') then
  formatters_by_ft.rust = { lsp_format = 'prefer' }
end

-- Markdown
if hasLang('markdown') then
  formatters_by_ft.markdown = { 'prettierd', 'prettier', stop_after_first = true }
end

-- Terraform
if hasLang('terraform') then
  formatters_by_ft.terraform = { 'tofu_fmt', 'terraform_fmt', stop_after_first = true }
  formatters_by_ft.tf = { 'tofu_fmt', 'terraform_fmt', stop_after_first = true }
end

require('conform').setup({
  formatters_by_ft = formatters_by_ft,

  default_format_opts = {
    lsp_format = 'fallback',
  },
})

-- Format keymap
vim.keymap.set('n', '<leader>bf', function()
  require('conform').format({ async = true, lsp_format = 'fallback' })
end, { desc = 'Format buffer' })

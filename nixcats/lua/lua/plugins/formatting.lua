-- nixcats/lua/plugins/formatting.lua
-- conform.nvim configuration (replaces neoformat)

local ok, conform = pcall(require, 'conform')
if not ok then
  vim.notify('conform.nvim not found', vim.log.levels.WARN)
  return
end

local nixCats = require('nixCats')
local function hasLang(lang)
  return nixCats.cats["languages." .. lang]
end

-- Per-filetype formatters. Only register those whose language category is
-- enabled — avoids conform complaining about missing external binaries.
local formatters_by_ft = {
  lua = { 'stylua' },
}

if hasLang('nix') then
  formatters_by_ft.nix = { 'alejandra' }
end

if hasLang('dotnet') then
  formatters_by_ft.cs = { 'csharpier' }
end

if hasLang('python') then
  formatters_by_ft.python = { 'black' }
end

if hasLang('rust') then
  formatters_by_ft.rust = { 'rustfmt' }
end

if hasLang('typescript') then
  local prettier = { 'prettier' }
  formatters_by_ft.javascript = prettier
  formatters_by_ft.javascriptreact = prettier
  formatters_by_ft.typescript = prettier
  formatters_by_ft.typescriptreact = prettier
  formatters_by_ft.vue = prettier
  formatters_by_ft.css = prettier
  formatters_by_ft.scss = prettier
  formatters_by_ft.html = prettier
end

if hasLang('json') then
  formatters_by_ft.json = { 'prettier' }
  formatters_by_ft.jsonc = { 'prettier' }
end

if hasLang('markdown') then
  formatters_by_ft.markdown = { 'prettier' }
end

if hasLang('sql') then
  formatters_by_ft.sql = { 'pg_format' }
end

if hasLang('kotlin') then
  formatters_by_ft.kotlin = { 'ktlint' }
end

if hasLang('terraform') then
  formatters_by_ft.terraform = { 'terraform_fmt' }
  formatters_by_ft.tf = { 'terraform_fmt' }
  formatters_by_ft.hcl = { 'terraform_fmt' }
end

conform.setup({
  formatters_by_ft = formatters_by_ft,
  default_format_opts = {
    timeout_ms = 3000,
  },
  -- No custom formatter overrides needed — csharpier is on PATH via nixcats
  -- wrapper (lspsAndRuntimeDeps in dotnet.nix), and conform's built-in
  -- csharpier formatter handles the correct args automatically.
})

-- <leader>lf: prefer LSP formatting, fall back to external formatter.
-- Fast path for C# (Roslyn), TS (ts_ls), etc.
vim.keymap.set('n', '<leader>lf', function()
  conform.format({ async = true, lsp_format = 'prefer' })
end, { desc = 'Format buffer (LSP)' })

-- <leader>bf: always use external formatter, skip LSP.
-- For when you specifically want csharpier/prettier/etc. over the LSP.
vim.keymap.set({ 'n', 'v' }, '<leader>bf', function()
  conform.format({ async = true, lsp_format = 'never' })
end, { desc = 'Format buffer (external)' })

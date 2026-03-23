-- nixcats/lua/plugins/formatting.lua
-- Neoformat configuration

local nixCats = require('nixCats')

-- Helper to check language categories
local function hasLang(lang)
  return nixCats.cats["languages." .. lang]
end

-- Only message on errors
vim.g.neoformat_only_msg_on_error = 1

-- Lua is always available
vim.g.neoformat_enabled_lua = { 'stylua' }

-- Configure formatters based on enabled languages
if hasLang('nix') then
  vim.g.neoformat_enabled_nix = { 'alejandra' }
end

if hasLang('dotnet') then
  -- Define custom csharpier formatter with nix store path
  local csharpierPath = nixCats('csharpierPath')
  if csharpierPath then
    vim.g.neoformat_cs_csharpier = {
      exe = csharpierPath,
      args = { '--write-stdout' },
      stdin = 1,
    }
  end
  vim.g.neoformat_enabled_cs = { 'csharpier' }
end

if hasLang('python') then
  vim.g.neoformat_enabled_python = { 'black' }
end

if hasLang('rust') then
  vim.g.neoformat_enabled_rust = { 'rustfmt' }
end

if hasLang('typescript') then
  vim.g.neoformat_enabled_javascript = { 'prettier' }
  vim.g.neoformat_enabled_javascriptreact = { 'prettier' }
  vim.g.neoformat_enabled_typescript = { 'prettier' }
  vim.g.neoformat_enabled_typescriptreact = { 'prettier' }
  vim.g.neoformat_enabled_vue = { 'prettier' }
  vim.g.neoformat_enabled_css = { 'prettier' }
  vim.g.neoformat_enabled_scss = { 'prettier' }
  vim.g.neoformat_enabled_html = { 'prettier' }
end

if hasLang('json') then
  vim.g.neoformat_enabled_json = { 'prettier' }
  vim.g.neoformat_enabled_jsonc = { 'prettier' }
end

if hasLang('markdown') then
  vim.g.neoformat_enabled_markdown = { 'prettier' }
end

if hasLang('sql') then
  vim.g.neoformat_enabled_sql = { 'pg_format' }
end

if hasLang('terraform') then
  vim.g.neoformat_enabled_terraform = { 'terraform_fmt' }
  vim.g.neoformat_enabled_tf = { 'terraform_fmt' }
  vim.g.neoformat_enabled_hcl = { 'terraform_fmt' }
end

-- Keymaps
vim.keymap.set({ 'n', 'v' }, '<leader>bf', '<cmd>Neoformat<CR>', { desc = 'Format buffer' })

-- <leader>lf for LSP-only format (when you explicitly want LSP)
vim.keymap.set('n', '<leader>lf', function()
  vim.lsp.buf.format({ async = true })
end, { desc = 'Format buffer (LSP)' })

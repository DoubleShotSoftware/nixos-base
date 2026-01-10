-- nixcats/lua/plugins/completion.lua
-- Completion configuration (blink.cmp)

local ok, blink = pcall(require, 'blink.cmp')
if not ok then
  vim.notify('blink.cmp not found', vim.log.levels.WARN)
  return
end

local nixCats = require('nixCats')

-- Build sources list
local default_sources = { 'lsp', 'path', 'snippets', 'buffer' }
local providers = {}

-- Add easy-dotnet source only if dotnet is enabled
if nixCats.cats["languages.dotnet"] then
  table.insert(default_sources, 'easy-dotnet')
  providers["easy-dotnet"] = {
    name = "easy-dotnet",
    enabled = true,
    module = "easy-dotnet.completion.blink",
    score_offset = 10000,
    async = true,
  }
end

blink.setup({
  keymap = {
    preset = 'super-tab',
    ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
    ['<C-e>'] = { 'hide' },
    ['<CR>'] = { 'accept', 'fallback' },
    ['<Tab>'] = { 'select_next', 'snippet_forward', 'fallback' },
    ['<S-Tab>'] = { 'select_prev', 'snippet_backward', 'fallback' },
    ['<C-p>'] = { 'select_prev', 'fallback' },
    ['<C-n>'] = { 'select_next', 'fallback' },
    ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
    ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },
  },
  appearance = {
    use_nvim_cmp_as_default = true,
    nerd_font_variant = 'mono',
  },
  sources = {
    default = default_sources,
    providers = providers,
  },
  completion = {
    documentation = {
      auto_show = true,
      auto_show_delay_ms = 200,
    },
    ghost_text = {
      enabled = true,
    },
  },
  signature = {
    enabled = true,
  },
})

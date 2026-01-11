-- nixcats/lua/plugins/completion.lua
-- Completion configuration (blink.cmp)
-- Direct translation from nixvim/plugins/blink-cmp.nix

local ok, blink = pcall(require, 'blink.cmp')
if not ok then
  vim.notify('blink.cmp not found', vim.log.levels.WARN)
  return
end

local nixCats = require('nixCats')

-- Build sources list (from nixvim)
local default_sources = { 'lsp', 'path', 'snippets' }
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

-- Direct translation from nixvim blink-cmp.nix settings
blink.setup({
  appearance = {
    use_nvim_cmp_as_default = false,
    nerd_font_variant = "normal",
  },
  completion = {
    accept = {
      auto_brackets = {
        enabled = false,
        semantic_token_resolution = { enabled = false },
      },
    },
    menu = {
      draw = {
        treesitter = { "lsp" },
        columns = { { "kind_icon" }, { "label", "label_description" } },
      },
    },
    documentation = {
      auto_show = true,
      auto_show_delay_ms = 200,
    },
    ghost_text = { enabled = vim.g.ai_cmp },
  },
  sources = {
    default = default_sources,
    providers = providers,
  },
  cmdline = { enabled = false },
  fuzzy = { implementation = "prefer_rust_with_warning" },
  keymap = {
    preset = "super-tab",
    ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
    ["<C-k>"] = { "show_signature", "hide_signature", "fallback" },
  },
  signature = {
    enabled = true,
    trigger = {
      enabled = true,
      show_on_keyword = false,
      blocked_trigger_characters = {},
      blocked_retrigger_characters = {},
      show_on_trigger_character = true,
      show_on_insert = false,
      show_on_insert_on_trigger_character = true,
    },
    window = { show_documentation = true },
  },
})

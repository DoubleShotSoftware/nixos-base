-- nixcats/lua/plugins/completion.lua
-- Completion configuration (blink.cmp + colorful-menu)

local ok, blink = pcall(require, 'blink.cmp')
if not ok then
  vim.notify('blink.cmp not found', vim.log.levels.WARN)
  return
end

-- Setup colorful-menu for enhanced completion highlighting
local cm_ok, colorful_menu = pcall(require, 'colorful-menu')
if cm_ok then
  colorful_menu.setup({
    ls = {
      lua_ls = { arguments_hl = "@comment" },
      gopls = {
        align_type_to_right = true,
        add_colon_before_type = false,
        preserve_type_when_truncate = true,
      },
      ts_ls = { extra_info_hl = "@comment" },
      vtsls = { extra_info_hl = "@comment" },
      ["rust-analyzer"] = {
        extra_info_hl = "@comment",
        align_type_to_right = true,
        preserve_type_when_truncate = true,
      },
      clangd = {
        extra_info_hl = "@comment",
        align_type_to_right = true,
        import_dot_hl = "@comment",
        preserve_type_when_truncate = true,
      },
      zls = { align_type_to_right = true },
      roslyn = { extra_info_hl = "@comment" },
      dartls = { extra_info_hl = "@comment" },
      basedpyright = { extra_info_hl = "@comment" },
      pylsp = {
        extra_info_hl = "@comment",
        arguments_hl = "@comment",
      },
      fallback = true,
      fallback_extra_info_hl = "@comment",
    },
    fallback_highlight = "@variable",
    max_width = 60,
  })
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
    preset = 'super-tab',  -- Tab accepts completion (like nixvim)
    ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
    ['<C-k>'] = { 'show_signature', 'hide_signature', 'fallback' },
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

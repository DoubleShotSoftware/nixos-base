-- nixcats/lua/plugins/ui-extras.lua
-- Additional UI enhancements: edgy, lsp-signature

-- Edgy: Window edge management for sidebars
local edgy_ok, edgy = pcall(require, 'edgy')
if edgy_ok then
  edgy.setup({
    -- Default configuration works well
    -- Customize positioning of neo-tree, trouble, etc.
  })
end

-- LSP Signature: Floating signature help while typing
local sig_ok, lsp_signature = pcall(require, 'lsp_signature')
if sig_ok then
  lsp_signature.setup({
    bind = true,
    handler_opts = {
      border = "rounded",
    },
    hint_enable = true,
    hint_prefix = " ",
    floating_window = true,
    floating_window_above_cur_line = true,
  })
end

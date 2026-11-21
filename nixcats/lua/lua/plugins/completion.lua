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

-- Disabled pending verification that stock blink handles kotlin-lsp's
-- two-phase apply flow correctly on its own.
--
-- Walkthrough of the stock flow per the lsp.log evidence captured at
-- 22:45:09 (workspace/applyEdit + window/showDocument):
--   1. blink's `default_implementation` (apply_item) runs against the
--      empty-newText textEdit: no-op insertion, cursor lands at
--      range.start (col 6 — middle of the eventual word).
--   2. blink fires the kotlin completion-apply command via exec_cmd.
--   3. Server's `workspace/applyEdit` inserts the full word at col 6.
--   4. Server's `window/showDocument` sets `selection.start` to col 10
--      (range.start + len(word)). nvim's stock showDocument handler
--      calls `nvim_win_set_cursor(win, { row+1, 10 })`.
--
-- Step 4 overrides step 1's mid-word placement, leaving the cursor at
-- end-of-insertion — which is the right answer. The wrapper at
-- `~/dev/easy-kotlin/lua/easy-kotlin/blink_source.lua` is kept on disk
-- for now in case re-testing reveals stock blink doesn't actually
-- behave as the log analysis predicts; if it does, the wrapper file
-- and this entire block can be deleted in a follow-up.
--
-- if nixCats.cats["languages.kotlin"] then
--   providers["lsp"] = {
--     module = "easy-kotlin.blink_source",
--   }
-- end

-- Direct translation from nixvim blink-cmp.nix settings
blink.setup({
  appearance = {
    use_nvim_cmp_as_default = false,
    nerd_font_variant = "normal",
  },
  completion = {
    accept = {
      -- Default is 100ms which is too tight for JVM-based LSPs (kotlin-lsp,
      -- jdtls): completionItem/resolve carries the `additionalTextEdits`
      -- that contain auto-imports, and if it doesn't return in time blink
      -- falls back to the unresolved item — symbol gets inserted but no
      -- import statement appears. Tab "works" today only because hovering
      -- pre-resolves the item via documentation; <CR> with no pause races.
      resolve_timeout_ms = 1000,
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
    ["<CR>"] = { "accept", "fallback" },
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

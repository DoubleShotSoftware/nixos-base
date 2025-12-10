function(entry, vim_item)
  local source_icons = {
      nvim_lsp = "",     -- you can pick any icon
      buffer   = "",
      luasnip  = "",
      path     = "📁",
      nvim_lua = "",
      treesitter= "󰐆";
      git= "";
    }
  local lspkind = require('lspkind')
  local highlights_info = require("colorful-menu").cmp_highlights(entry)
  local source_name = entry.source.name
  local source_icon = source_icons[source_name] or ""  -- fallback icon
  local kind_icon = lspkind.symbol_map[vim_item.kind] or ""
    -- A Unicode delimiter (choose what you like: "→", "»", "", etc.)
  local arrow = "  "

  -- Combine them in the "kind" field to show a parent/child relationship
  -- Example:  →  or  →  etc.
  vim_item.kind = string.format("%s %s %s", source_icon, arrow, kind_icon)

  -- Make the *item name* semibold & underlined:
  -- We'll store the raw label in vim_item.abbr
  -- and then assign a highlight group for it:
  -- vim_item.abbr_hl_group = "CmpItemAbbrSemiboldUnderline"
  -- If you want the entire "kind" field in italic, do:
  -- vim_item.kind_hl_group = "CmpItemKindLightItalic"

  -- Insert detail (namespace, module, etc.) into the "menu" field
  local module_info = ""
  if entry.completion_item.detail and entry.completion_item.detail ~= "" then
    module_info = entry.completion_item.detail
  elseif entry.completion_item.labelDetails
      and entry.completion_item.labelDetails.description
      and entry.completion_item.labelDetails.description ~= "" then
    module_info = entry.completion_item.labelDetails.description
  end
  vim_item.menu = (module_info ~= "") and ("- " .. module_info) or ""
    if highlights_info ~= nil then
        vim_item.abbr_hl_group = highlights_info.highlights
        vim_item.abbr = highlights_info.text
    end
  return vim_item
end

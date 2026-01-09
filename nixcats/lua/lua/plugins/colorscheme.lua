-- nixcats/lua/plugins/colorscheme.lua
-- Theme-aware colorscheme configuration with contrast tweaks

local nixCats = require('nixCats')
local theme = nixCats.extra.theme or 'tokyonight'

-- Tokyonight setup
if theme == 'tokyonight' then
  require('tokyonight').setup({
    style = 'night',
    transparent = true,
    terminal_colors = true,
    dim_inactive = true,
    lualine_bold = false,
    sidebars = { 'qf', 'vista_kind', 'terminal', 'packer', 'neo-tree' },
    day_brightness = 0.3,
    styles = {
      comments = { italic = true },
      keywords = { italic = true },
      functions = {},
      variables = {},
      sidebars = 'dark',
      floats = 'dark',
    },
    on_highlights = function(hl, colors)
      -- Line numbers with better contrast
      hl.LineNr = {
        fg = colors.orange,
        bold = true,
        bg = colors.bg_dark,
      }
      hl.CursorLineNr = {
        fg = colors.orange,
        bold = true,
        bg = colors.bg_dark,
      }
      hl.LineNrAbove = {
        fg = colors.blue,
        bg = colors.bg_dark,
      }
      hl.LineNrBelow = {
        fg = colors.blue,
        bg = colors.bg_dark,
      }

      -- Gutter background
      hl.SignColumn = { bg = colors.bg_dark }
      hl.FoldColumn = { bg = colors.bg_dark }

      -- Git signs with dark background
      hl.GitSignsAdd = { fg = colors.green, bg = colors.bg_dark }
      hl.GitSignsChange = { fg = colors.blue, bg = colors.bg_dark }
      hl.GitSignsDelete = { fg = colors.red, bg = colors.bg_dark }

      -- LSP diagnostics with dark background
      hl.DiagnosticSignError = { fg = colors.red, bg = colors.bg_dark }
      hl.DiagnosticSignWarn = { fg = colors.yellow, bg = colors.bg_dark }
      hl.DiagnosticSignInfo = { fg = colors.blue, bg = colors.bg_dark }
      hl.DiagnosticSignHint = { fg = colors.cyan, bg = colors.bg_dark }
    end,
  })
  vim.cmd.colorscheme('tokyonight')

-- Catppuccin setup
elseif theme == 'catppuccin' then
  require('catppuccin').setup({
    flavour = 'mocha',
    transparent_background = true,
    term_colors = true,
    dim_inactive = { enabled = true },
    integrations = {
      cmp = true,
      gitsigns = true,
      nvimtree = true,
      treesitter = true,
      notify = true,
      mini = true,
      telescope = { enabled = true },
      which_key = true,
      indent_blankline = { enabled = true },
      native_lsp = {
        enabled = true,
        virtual_text = {
          errors = { 'italic' },
          hints = { 'italic' },
          warnings = { 'italic' },
          information = { 'italic' },
        },
        underlines = {
          errors = { 'underline' },
          hints = { 'underline' },
          warnings = { 'underline' },
          information = { 'underline' },
        },
      },
    },
    custom_highlights = function(colors)
      return {
        -- Line numbers with better contrast
        LineNr = { fg = colors.peach, bold = true, bg = colors.mantle },
        CursorLineNr = { fg = colors.peach, bold = true, bg = colors.mantle },
        LineNrAbove = { fg = colors.blue, bg = colors.mantle },
        LineNrBelow = { fg = colors.blue, bg = colors.mantle },

        -- Gutter background
        SignColumn = { bg = colors.mantle },
        FoldColumn = { bg = colors.mantle },

        -- Git signs with dark background
        GitSignsAdd = { fg = colors.green, bg = colors.mantle },
        GitSignsChange = { fg = colors.blue, bg = colors.mantle },
        GitSignsDelete = { fg = colors.red, bg = colors.mantle },

        -- LSP diagnostics with dark background
        DiagnosticSignError = { fg = colors.red, bg = colors.mantle },
        DiagnosticSignWarn = { fg = colors.yellow, bg = colors.mantle },
        DiagnosticSignInfo = { fg = colors.blue, bg = colors.mantle },
        DiagnosticSignHint = { fg = colors.teal, bg = colors.mantle },
      }
    end,
  })
  vim.cmd.colorscheme('catppuccin')
end

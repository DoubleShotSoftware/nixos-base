-- nixcats/lua/core/options.lua
-- Neovim options configuration

local opt = vim.opt

-- Leader keys
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Clipboard
-- opt.clipboard = 'unnamedplus'  -- Use system clipboard

-- Indentation
opt.breakindent = true
opt.smartindent = true
opt.expandtab = true
opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2

-- UI
opt.cmdheight = 2
opt.conceallevel = 0
opt.pumheight = 10
opt.showmode = false
opt.showtabline = 2
opt.termguicolors = true
opt.laststatus = 3
opt.cursorline = true
opt.cursorlineopt = 'number'
opt.number = true
opt.relativenumber = true
opt.numberwidth = 2
opt.signcolumn = 'yes'
opt.colorcolumn = '120'
opt.wrap = false
opt.scrolloff = 8
opt.sidescrolloff = 8

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = false
opt.incsearch = true

-- Splits
opt.splitbelow = true
opt.splitright = true

-- Window separators (thicker dividers)
opt.fillchars = {
  horiz = '━',
  horizup = '┻',
  horizdown = '┳',
  vert = '┃',
  vertleft = '┫',
  vertright = '┣',
  verthoriz = '╋',
  eob = ' ',  -- Remove ~ at end of buffer
}

-- Performance
opt.timeoutlen = 1000
opt.updatetime = 50
opt.writebackup = false

-- Files
opt.fileencoding = 'utf-8'

-- Mouse
opt.mouse = 'a'

-- Folding (treesitter-based)
opt.foldmethod = 'expr'
opt.foldexpr = 'nvim_treesitter#foldexpr()'
opt.foldenable = true
opt.foldlevel = 99
opt.foldlevelstart = 99

-- Diagnostics
vim.diagnostic.config({
  virtual_text = true,
  virtual_lines = { current_line = true },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = 'rounded',
    source = 'always',
  },
})

-- Diagnostic signs
local signs = { Error = ' ', Warn = ' ', Info = ' ', Hint = '󰌵 ' }
for type, icon in pairs(signs) do
  local hl = 'DiagnosticSign' .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

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

-- Folding: handled by nvim-ufo (LSP → treesitter → indent fallback).
-- ufo requires foldlevel/foldlevelstart = 99 so its virtual fold text can
-- render; the desired default depth is applied via ufo.closeFoldsWith in
-- plugins/folding.lua.
opt.foldmethod = 'manual'
opt.foldenable = true
opt.foldlevel = 99
opt.foldlevelstart = 99
vim.o.fillchars = "foldclose:󰅂,foldopen:󰅀"
-- https://neovim.io/doc/user/options/#'fillchars'
--vim.o.fillchars = 'eob: ,fold: ,foldopen:,foldsep: ,foldinner: ,foldclose:'

-- Diagnostics (nvim 0.11+: signs defined via vim.diagnostic.config instead of sign_define)
local severity = vim.diagnostic.severity
vim.diagnostic.config({
  virtual_text = true,
  virtual_lines = { current_line = true },
  signs = {
    text = {
      [severity.ERROR] = '󰅚 ', -- nf-md-close_circle_outline
      [severity.WARN]  = '󰀪 ', -- nf-md-alert
      [severity.INFO]  = '󰋽 ', -- nf-md-information_outline
      [severity.HINT]  = '󰌵 ', -- nf-md-lightbulb_outline
    },
    texthl = {
      [severity.ERROR] = 'DiagnosticSignError',
      [severity.WARN]  = 'DiagnosticSignWarn',
      [severity.INFO]  = 'DiagnosticSignInfo',
      [severity.HINT]  = 'DiagnosticSignHint',
    },
    numhl = {
      [severity.ERROR] = 'DiagnosticSignError',
      [severity.WARN]  = 'DiagnosticSignWarn',
      [severity.INFO]  = 'DiagnosticSignInfo',
      [severity.HINT]  = 'DiagnosticSignHint',
    },
  },
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = 'rounded',
    source = 'always',
  },
})

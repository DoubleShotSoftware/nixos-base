require("nvim-tree").setup({
  sort_by = "case_sensitive",
  view = {
    width = 32
  },
  renderer = {
    group_empty = true,
    highlight_git = true,
  },
  filters = {
    dotfiles = true,
  },
  update_focused_file = {
    enable = true
  },
  git = {
    enable = true,
    ignore = true
  }
})
vim.api.nvim_set_keymap(
  "n",
  "<space>e",
  ":NvimTreeToggle<CR>",
  { noremap = true }
)

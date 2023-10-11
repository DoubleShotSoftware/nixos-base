require('nightfox').setup({
  options = {
    transparent = true;
    terminal_colors = true;
    styles = {
      comments = "italic",
      keywords = "bold",
      types = "italic,bold",
    }
  }
})
vim.cmd("colorscheme carbonfox")

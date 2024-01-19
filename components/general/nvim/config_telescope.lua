require("telescope")
local keymap = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }
require("telescope").setup{
  defaults = {
	file_ignore_patterns = {
		  "node_modules",
		  "dist",
		  "out",
		  "target"
	},
	vimgrep_arguments = {
		"rg",
		"--color=never",
		"--no-heading",
		"--with-filename",
		"--line-number",
		"--column",
		"--smart-case",
		"--trim"
	}
  },
  extensions = {
    file_browser = {
      theme = "tokyonight-night",
      hijack_netrw = true,
      mappings = {
        ["i"] = {
        },
        ["n"] = {
        },
      },
    },
  }
}
keymap("n", "<leader>g", "<cmd>Telescope live_grep<cr>", opts)
keymap("n", "<leader>f", "<cmd>lua require'telescope.builtin'.find_files(require('telescope.themes').get_dropdown({ previewer = false }))<cr>", opts)
keymap("n", "<leader>d", "<cmd>lua require'telescope.builtin'.lsp_document_symbols(require('telescope.themes').get_cursor({ previewer = false }))<cr>", opts)
keymap("n", "<leader>b", "<cmd>lua require'telescope.builtin'.git_branches(require('telescope.themes').get_dropdown({ previewer = false }))<cr>", opts)

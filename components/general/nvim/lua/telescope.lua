local opts = { noremap = true, silent = true }
local helpers = require("user.helpers")
require("telescope").setup({
	defaults = {
		file_ignore_patterns = {
			"node_modules",
			"dist",
			"out",
			"target",
            "obj",
            "bin"
		},
		vimgrep_arguments = {
			"rg",
			"--color=never",
			"--no-heading",
			"--with-filename",
			"--line-number",
			"--column",
			"--smart-case",
			"--trim",
		},
	},
	extensions = {
		file_browser = {
			theme = "tokyonight-night",
			hijack_netrw = true,
			mappings = {
				["i"] = {},
				["n"] = {},
			},
		},
	},
})

-- Load Extensions
pcall(require("telescope").load_extension, "fzf")
require("telescope").load_extension("media_files")

-- Telescope live_grep in git root

-- Custom live_grep function to search in git root
local function live_grep_git_root()
	local git_root = helpers.find_git_root()
	if git_root then
		require("telescope.builtin").live_grep({
			search_dirs = { git_root },
		})
	end
end
vim.api.nvim_create_user_command("LiveGrepGitRoot", live_grep_git_root, {})

-- Define Keymaps
vim.keymap.set("n", "<leader>?", require("telescope.builtin").oldfiles, { desc = "[?] Find recently opened files." })

-- Search from relative
-- Search from git root
vim.keymap.set("n", "<leader>sg", ":LiveGrepGitRoot<cr>", { desc = "[s]earch by [g]rep on Git Root" })

vim.keymap.set("n", "<leader>sb", "<cmd>Telescope buffers<cr>", { desc = "[s]earch [b]uffers" })
vim.keymap.set(
	"n",
	"<leader>sf",
	"<cmd>Telescope find_files<cr>",
	{ desc = "[s]earch [f]iles" }
)
vim.keymap.set(
	"n",
	"<leader>sc",
	"<cmd>Telescope commands<cr>",
	{ desc = "[s]earch [c]ommands" }
)
vim.keymap.set(
	"n",
	"<leader>sd",
	"<cmd>lua require'telescope.builtin'.lsp_document_symbols(require('telescope.themes').get_cursor({ previewer = false }))<cr>",
	{ desc = "[s]earch [d]ocument symbols" }
)
vim.keymap.set(
	"n",
	"<leader>sB",
	"<cmd>Telescope git_branches<cr>",
	{ desc = "[s]earch git [B]ranches" }
)
vim.keymap.set(
	"n",
	"<leader>sS",
	"<cmd>Telescope git_status<cr>",
	{ desc = "[s]earch git [S]tatus" }
)
vim.keymap.set(
	"n",
	"<leader>ss",
	"<cmd>Telescope lsp_workspace_symbols<cr>",
	{ desc = "[s]earch workspace [s]ymbols" }
)
vim.keymap.set(
	"n",
	"<leader>sGB",
	"<cmd>lua require'telescope.builtin'.git_branches(require('telescope.themes').get_dropdown({ previewer = false }))<cr>",
	{ desc = "[s]earch [G]it [B]ranches" }
)
vim.keymap.set("n", "<leader>sh", require("telescope.builtin").help_tags, { desc = "[S]earch [H]elp" })
vim.keymap.set("n", "<leader>sw", require("telescope.builtin").grep_string, { desc = "[S]earch current [W]ord" })
vim.keymap.set("n", "<leader>sd", require("telescope.builtin").diagnostics, { desc = "[S]earch [D]iagnostics" })
vim.keymap.set("n", "<leader>sr", require("telescope.builtin").resume, { desc = "[S]earch [R]esume" })
vim.keymap.set("n", "<leader>sa", require("telescope.builtin").commands, { desc = "[s]each [a]ctions" })
vim.keymap.set(
	"n",
	"<leader>sah",
	require("telescope.builtin").command_history,
	{ desc = "[s]each [a]ction [h]istory" }
)

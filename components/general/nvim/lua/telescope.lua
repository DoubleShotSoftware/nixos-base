local opts = { noremap = true, silent = true }
require("telescope").setup({
	defaults = {
		file_ignore_patterns = {
			"node_modules",
			"dist",
			"out",
			"target",
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
-- Function to find the git root directory based on the current buffer's path
local function find_git_root()
	-- Use the current buffer's path as the starting point for the git search
	local current_file = vim.api.nvim_buf_get_name(0)
	local current_dir
	local cwd = vim.fn.getcwd()
	-- If the buffer is not associated with a file, return nil
	if current_file == "" then
		current_dir = cwd
	else
		-- Extract the directory from the current file's path
		current_dir = vim.fn.fnamemodify(current_file, ":h")
	end

	-- Find the Git root directory from the current file's path
	local git_root = vim.fn.systemlist("git -C " .. vim.fn.escape(current_dir, " ") .. " rev-parse --show-toplevel")[1]
	if vim.v.shell_error ~= 0 then
		print("Not a git repository. Searching on current working directory")
		return cwd
	end
	return git_root
end

-- Custom live_grep function to search in git root
local function live_grep_git_root()
	local git_root = find_git_root()
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
	"<cmd>lua require'telescope.builtin'.find_files(require('telescope.themes').get_dropdown({ previewer = false }))<cr>",
	{ desc = "[s]earch [f]iles" }
)
vim.keymap.set(
	"n",
	"<leader>sd",
	"<cmd>lua require'telescope.builtin'.lsp_document_symbols(require('telescope.themes').get_cursor({ previewer = false }))<cr>",
	{ desc = "[s]earch [d]ocument symbols" }
)

vim.keymap.set(
	"n",
	"<leader>sGB",
	"<cmd>lua require'telescope.builtin'.git_branches(require('telescope.themes').get_dropdown({ previewer = false }))<cr>",
	{ desc = "[s]earch [G]it [B]ranches" }
)
vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sr', require('telescope.builtin').resume, { desc = '[S]earch [R]esume' })

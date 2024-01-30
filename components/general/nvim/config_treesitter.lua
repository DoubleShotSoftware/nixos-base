require("nvim-treesitter.install").compilers = {  "clang++", "clang" }
local languages = require("lsp.treesitter").setup()

require('nvim-treesitter.configs').setup({
	ensure_installed = languages,
parser_install_dir = string.format("%s/.local/share/nvim/treesitter/parsers", os.getenv("HOME")),
  ignore_install = { "bash", "sh" },
	auto_install = false,
	highlight = {
		enable = true,
    disable = {"bash", "sh"},
		additional_vim_regex_highlighting = true,
	},
	indent = {
		enable = true
	},
})


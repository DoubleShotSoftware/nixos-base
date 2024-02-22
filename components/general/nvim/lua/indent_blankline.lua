local highlight = {
	"RainbowEven",
	"RainbowOdd",
	"RainbowEven",
	"RainbowOdd",
	"RainbowEven",
	"RainbowOdd",
	"RainbowEven",
	"RainbowOdd",
	"RainbowEven",
	"RainbowOdd",
	"RainbowEven",
	"RainbowOdd",
}

local hooks = require("ibl.hooks")
-- create the highlight groups in the highlight setup hook, so they are reset
-- every time the colorscheme changes
hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
	-- vim.api.nvim_set_hl(0, "RainbowEven", { fg = "#bb9af7" })
	-- vim.api.nvim_set_hl(0, "RainbowOdd", { fg = "#ff9e64" })
	vim.api.nvim_set_hl(0, "RainbowEven", { fg = "#24283b" })
	vim.api.nvim_set_hl(0, "RainbowOdd", { fg = "#565f89" })
end)

require("ibl").setup({ indent = { highlight = highlight } })

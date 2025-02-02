if not vim.g.neovide then
	return {}
end

local alpha = function()
	return string.format("%x", math.floor(255 * vim.g.transparency or 0.8))
end

vim.g.neovide_theme = "auto"
vim.o.guifont = "VictorMono Nerd Font:h10,FiraCode Nerd Font:h10" -- text below applies for VimScript
vim.g.neovide_transparency = 0.0
vim.g.transparency = 0.8
vim.g.neovide_background_color = "#0f1117" .. alpha()

vim.g.neovide_scale_factor = 1.0
local change_scale_factor = function(delta)
	vim.g.neovide_scale_factor = vim.g.neovide_scale_factor * delta
end
vim.keymap.set("n", "<C-=>", function()
	change_scale_factor(1.25)
end)
vim.keymap.set("n", "<C-->", function()
	change_scale_factor(1 / 1.25)
end)

vim.g.clipboad = { -- Trying to resolve issues using this. (Enable System-clipboard functionality.)
	name = "xsel",
	copy = {
		["+"] = "xsel --nodetach -ib",
		["*"] = "xsel --nodetach -ip",
	},
	paste = {
		["+"] = "xsel -ob",
		["*"] = "xsel -op",
	},
	cache_enabled = true,
}

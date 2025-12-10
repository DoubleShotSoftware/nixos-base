local dashboard = require("alpha.themes.dashboard")

-- Keep the original ASCII art you like
local header = {
	[[                                                                       ]],
	[[                                                                     ]],
	[[       ████ ██████           █████      ██                     ]],
	[[      ███████████             █████                             ]],
	[[      █████████ ███████████████████ ███   ███████████   ]],
	[[     █████████  ███    █████████████ █████ ██████████████   ]],
	[[    █████████ ██████████ █████████ █████ █████ ████ █████   ]],
	[[  ███████████ ███    ███ █████████ █████ █████ ████ █████  ]],
	[[ ██████  █████████████████████ ████ █████ █████ ████ ██████ ]],
	[[                                                                       ]],
}

-- Get version and stats
local function get_version()
	local v = vim.version()
	return string.format("v%d.%d.%d", v.major, v.minor, v.patch)
end

local function get_plugin_count()
	local count = #vim.tbl_keys(vim.g.plugs or {})
	if count == 0 then
		-- Try counting lazy.nvim plugins if available
		local ok, lazy = pcall(require, "lazy")
		if ok and lazy.stats then
			local stats = lazy.stats()
			count = stats.count or 0
		else
			-- Count vim packages
			local packpath = vim.o.packpath
			if packpath then
				count = 0
				for path in packpath:gmatch("[^,]+") do
					local plugin_dir = path .. "/pack/*/start/*"
					local handle = vim.loop.fs_scandir(path .. "/pack")
					if handle then
						vim.loop.fs_scandir_next(handle)
						count = count + 1
					end
				end
			end
		end
	end
	return count
end

-- Improved footer with useful info
local function get_footer()
	local version = get_version()
	local plugin_count = get_plugin_count()

	return {
		"",
		"──────────────────────────────────────────────────────",
		string.format("⚡ Neovim %s  •  📦 %d plugins loaded", version, plugin_count),
		"──────────────────────────────────────────────────────",
	}
end

dashboard.section.header.val = header

-- Fixed button actions with working commands
dashboard.section.buttons.val = {
	dashboard.button("i", "    new file", ":ene <BAR> startinsert<CR>"),
	dashboard.button("o", "    old files", ":Telescope oldfiles<CR>"),
	dashboard.button("f", "󰥨    find file", ":Telescope find_files<CR>"),
	dashboard.button("g", "󰱼    find text", ":Telescope live_grep<CR>"),
	dashboard.button("h", "    browse git", ':lua require("snacks").lazygit()<CR>'),  -- Fixed: Use LazyGit
	dashboard.button("s", "    restore session", ':lua require("resession").load("last")<CR>'),  -- Fixed: Use resession
	dashboard.button("c", "    config", ":e $MYVIMRC<CR>"),
	dashboard.button("q", "󰭿    quit", ":qa<CR>"),
}

-- Button styling
for _, button in ipairs(dashboard.section.buttons.val) do
	button.opts.hl = "AlphaButtons"
	button.opts.hl_shortcut = "AlphaShortcut"
end

-- Set highlight groups
dashboard.section.header.opts.hl = "AlphaHeader"
dashboard.section.buttons.opts.hl = "AlphaButtons"
dashboard.section.footer.opts.hl = "AlphaFooter"

-- Update footer dynamically
dashboard.section.footer.val = get_footer()

-- Layout configuration with better spacing
dashboard.opts.layout = {
	{ type = "padding", val = 2 },
	dashboard.section.header,
	{ type = "padding", val = 3 },
	dashboard.section.buttons,
	{ type = "padding", val = 2 },
	dashboard.section.footer,
}

-- Refresh footer on BufEnter
vim.api.nvim_create_autocmd("User", {
	pattern = "AlphaReady",
	callback = function()
		dashboard.section.footer.val = get_footer()
		pcall(vim.cmd, "AlphaRedraw")
	end,
})

-- Set up highlights (these will be set after colorscheme loads)
vim.api.nvim_create_autocmd("ColorScheme", {
	callback = function()
		vim.api.nvim_set_hl(0, "AlphaHeader", { fg = "#7aa2f7", bold = true })
		vim.api.nvim_set_hl(0, "AlphaButtons", { fg = "#c0caf5" })
		vim.api.nvim_set_hl(0, "AlphaShortcut", { fg = "#ff9e64", bold = true })
		vim.api.nvim_set_hl(0, "AlphaFooter", { fg = "#565f89", italic = true })
	end,
})

-- Also set them now in case colorscheme is already loaded
pcall(function()
	vim.api.nvim_set_hl(0, "AlphaHeader", { fg = "#7aa2f7", bold = true })
	vim.api.nvim_set_hl(0, "AlphaButtons", { fg = "#c0caf5" })
	vim.api.nvim_set_hl(0, "AlphaShortcut", { fg = "#ff9e64", bold = true })
	vim.api.nvim_set_hl(0, "AlphaFooter", { fg = "#565f89", italic = true })
end)

require("alpha").setup(dashboard.opts)
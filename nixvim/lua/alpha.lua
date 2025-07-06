local dashboard = require("alpha.themes.dashboard")
local header = {
	[[                                                                       ]],
	[[                                                                     ]],
	[[       ████ ██████           █████      ██                     ]],
	[[      ███████████             █████                             ]],
	[[      █████████ ███████████████████ ███   ███████████   ]],
	[[     █████████  ███    █████████████ █████ ██████████████   ]],
	[[    █████████ ██████████ █████████ █████ █████ ████ █████   ]],
	[[  ███████████ ███    ███ █████████ █████ █████ ████ █████  ]],
	[[ ██████  █████████████████████ ████ █████ █████ ████ ██████ ]],
	[[                                                                       ]],
}
local footer = {
	"                                      n e o v i m   ",
	"▄ ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄ ▄ ▄▄▄▄▄▄▄▄▄▄▄▄▄ ▄",
}
dashboard.section.header.val = header
dashboard.section.footer.val = footer
dashboard.section.buttons.val = {
	dashboard.button("i", "    new file", ":ene <BAR> startinsert<CR>"),
	dashboard.button("o", "    old files", ":Telescope oldfiles<CR>"),
	dashboard.button("f", "󰥨    find file", ":Telescope find_files<CR>"),
	dashboard.button("g", "󰱼    find text", ":Telescope live_grep_args<CR>"),
	dashboard.button("h", "    browse git", ":Flog<CR>"),
	dashboard.button("s", " " .. " Restore Session", ':lua require("persistence").load() <cr>'),
	dashboard.button("q", "󰭿    quit", ":qa<CR>"),
}
for _, button in ipairs(dashboard.section.buttons.val) do
	button.opts.hl = "Normal"
	button.opts.hl_shortcut = "Function"
end
dashboard.section.footer.opts.hl = "Special"
dashboard.opts.layout = {
	dashboard.section.header,
	{ type = "padding", val = 4 },
	dashboard.section.buttons,
	dashboard.section.footer,
}
require("alpha").setup(dashboard.opts)

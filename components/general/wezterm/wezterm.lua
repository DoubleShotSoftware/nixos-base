local wezterm = require("wezterm")
local wezterm = require("wezterm")
local SOLID_LEFT_ARROW = wezterm.nerdfonts.pl_right_hard_divider
local SOLID_RIGHT_ARROW = wezterm.nerdfonts.pl_left_hard_divider
return {
	font = wezterm.font("VictorMono Nerd Font"),
	automatically_reload_config = true,
	font_size = 14,
	line_height = 1.25,
	hide_tab_bar_if_only_one_tab = true,
	window_decorations = "RESIZE",
	window_close_confirmation = "NeverPrompt",
	show_update_window = false,
	enable_scroll_bar = false,
	color_scheme = "Catppuccin Mocha",
	window_background_opacity = 0.85,
	tab_bar_at_bottom = true,
	inactive_pane_hsb = {
		saturation = 0.9,
		brightness = 0.8,
	},
	window_frame = {
		font = wezterm.font("Fira Code"),
		font_size = 14,
		inactive_titlebar_bg = "#1e1e2e",
		active_titlebar_bg = "#2b2042",
	},
	colors = {
		tab_bar = {
			background = "#1e1e2e",
			active_tab = {
				bg_color = "#24283b",
				fg_color = "#cdd6f4",
			},
			inactive_tab = {
				fg_color = "#bac2de",
				bg_color = "#414868",
				italic = true,
			},
		},
	},
}

local wezterm = require 'wezterm'
-- The filled in variant of the < symbol
local SOLID_LEFT_ARROW = utf8.char(0xe0b2)

-- The filled in variant of the > symbol
local SOLID_RIGHT_ARROW = utf8.char(0xe0b0)
local fontFamily = "FiraCode Nerd Font"

local wezterm = require 'wezterm'

wezterm.on('update-status', function(window, pane)
  local meta = pane:get_metadata() or {}
  if meta.is_tardy then
    local secs = meta.since_last_response_ms / 1000.0
    window:set_right_status(string.format('tardy: %5.1fs⏳', secs))
  end
end)


local config = {
  automatically_reload_config = true,
  font_size = 12,
  line_height = 1.25,
  hide_tab_bar_if_only_one_tab = true,
  window_decorations = "RESIZE",
  window_close_confirmation = "NeverPrompt",
  show_update_window = false,
  enable_scroll_bar = false,
  color_scheme = "Dark Pastel",
  window_background_opacity = 0.85,
  tab_bar_at_bottom  = true,
  inactive_pane_hsb = {
    saturation = 0.9,
    brightness = 0.8,
  },
  colors = {
	  tab_bar = {
		  background = "#b4f9f8",
		  active_tab = {
			  bg_color = "#16161e",
			  fg_color = "#3d59a1",
		  },
		  inactive_tab = {
			  bg_color = "#16161e",
			  fg_color = "#787c99",
			  italic = true
		  }
	  }
  }
}

config.ssh_domains = {
}

config.font = wezterm.font '${fontFamily}'

return config

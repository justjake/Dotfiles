local wezterm = require("wezterm")

local config = wezterm.config_builder()
config.colors = {}

require("keys").setup(config)
require("links").setup(config)

config.color_scheme = "Circus (base16)"
local theme = {
	base00 = "#191919",
	base01 = "#202020",
	base02 = "#303030",
	base03 = "#5f5a60",
	base04 = "#505050",
	base05 = "#a7a7a7",
	base06 = "#808080",
	base07 = "#ffffff",
	base08 = "#dc657d",
	base09 = "#4bb1a7",
	base0A = "#c3ba63",
	base0B = "#84b97c",
	base0C = "#4bb1a7",
	base0D = "#639ee4",
	base0E = "#b888e2",
	base0F = "#b888e2",
}

config.initial_rows = 50
config.initial_cols = 140

config.font = wezterm.font({ family = "Monaco" })
config.font_size = 15
config.window_frame = {
	font = wezterm.font({ family = "Monaco", weight = "Bold" }),
	font_size = 15,
}
config.window_padding = {
	left = "0cell",
	right = "0cell",
	top = "0.5cell",
	bottom = "0.5cell",
}
config.window_decorations = "RESIZE"

-- Tab bar
-- https://wezfurlong.org/wezterm/config/appearance.html#retro-tab-bar-appearance
config.tab_bar_at_bottom = true
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.tab_max_width = 50

config.colors.tab_bar = {}
local tab_colors = config.colors.tab_bar
tab_colors.background = theme.base02
tab_colors.active_tab = {
	fg_color = theme.base00,
	bg_color = theme.base0D,
	intensity = "Bold",
}
tab_colors.inactive_tab = {
	fg_color = theme.base00,
	bg_color = theme.base06,
	intensity = "Bold",
}
tab_colors.inactive_tab_hover = tab_colors.inactive_tab
tab_colors.new_tab = {
	fg_color = tab_colors.inactive_tab.bg_color,
	bg_color = tab_colors.background,
	intensity = "Bold",
}
tab_colors.new_tab_hover = {
	fg_color = theme.base0D,
	bg_color = tab_colors.background,
	intensity = "Bold",
	italic = false,
}

-- https://wezfurlong.org/wezterm/config/lua/window-events/format-tab-title.html
-- This function returns the suggested title for a tab.
-- It prefers the title that was set via `tab:set_title()`
-- or `wezterm cli set-tab-title`, but falls back to the
-- title of the active pane in that tab.
function tab_title(tab_info)
	local title = tab_info.tab_title
	-- if the tab title is explicitly set, take that
	if title and #title > 0 then
		return title
	end
	-- Otherwise, use the title from the active pane
	-- in that tab
	return tab_info.active_pane.title
end
wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local title = tab_title(tab)
	local trimmed = wezterm.truncate_right(title, max_width - 2)
	local format = {
		{ Text = " " .. trimmed .. " " },
	}
	if tab.tab_index + 1 ~= #tabs then
		-- Not last tab: add padding to right
		table.insert(format, { Background = { Color = tab_colors.background } })
		table.insert(format, { Text = " " })
	end
	return format
end)
-- https://wezfurlong.org/wezterm/config/lua/wezterm/nerdfonts.html?h=clock
wezterm.on("update-right-status", function(window, pane)
	local date = wezterm.time.now():format_utc("%Y-%m-%d %H:%M UTC")
	window:set_right_status(wezterm.format({
		{ Text = date },
	}))
end)

local popup = {
	font_size = 22,
	fg_color = theme.base05,
	bg_color = theme.base02,
}

-- Command palette
-- https://wezfurlong.org/wezterm/config/lua/keyassignment/ActivateCommandPalette.html#key-assignments
config.command_palette_font_size = popup.font_size
config.command_palette_fg_color = popup.fg_color
config.command_palette_bg_color = popup.bg_color

-- Char select
-- https://wezfurlong.org/wezterm/config/lua/keyassignment/CharSelect.html
-- https://wezfurlong.org/wezterm/tags.html#char_select
config.char_select_font_size = 36
config.char_select_fg_color = popup.fg_color
config.char_select_bg_color = popup.bg_color

return config

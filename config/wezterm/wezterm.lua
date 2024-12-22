local wezterm = require("wezterm")

local config = wezterm.config_builder()
require("keys").setup(config)

config.color_scheme = "Circus (base16)"

config.font = wezterm.font({ family = "Monaco" })
config.font_size = 15
config.window_frame = {
	font = wezterm.font({ family = "Monaco", weight = "Bold" }),
	font_size = 14.0,
}

config.window_decorations = "RESIZE"
config.tab_bar_at_bottom = true

-- smart_splits.apply_to_config(config, {
-- 	-- the default config is here, if you'd like to use the default keys,
-- 	-- you can omit this configuration table parameter and just use
-- 	-- smart_splits.apply_to_config(config)
--
-- 	-- directional keys to use in order of: left, down, up, right
-- 	direction_keys = { "h", "j", "k", "l" },
-- 	-- if you want to use separate direction keys for move vs. resize, you
-- 	-- can also do this:
-- 	direction_keys = {
-- 		move = { "h", "j", "k", "l" },
-- 		resize = { "LeftArrow", "DownArrow", "UpArrow", "RightArrow" },
-- 	},
-- 	-- modifier keys to combine with direction_key
-- 	modifiers = {
-- 		move = "CTRL", -- modifier to use for pane movement, e.g. CTRL+h to move left
-- 		resize = "META", -- modifier to use for pane resize, e.g. META+h to resize to the left
-- 	},
-- 	-- log level to use: info, warn, error
-- 	log_level = "info",
-- })

print(config)
return config

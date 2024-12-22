local wezterm = require("wezterm")
local smart_splits = wezterm.plugin.require("https://github.com/mrjones2014/smart-splits.nvim")
local act = wezterm.action
local M = {}

-- you can put the rest of your Wezterm config here

wezterm.on("update-plugins", function(window, pane)
	wezterm.plugin.update_all()
	window:toast_notification("wezterm", "Plugins updated!", nil, 4000)
end)

wezterm.on("toggle-opacity", function(window, pane)
	local overrides = window:get_config_overrides() or {}
	if not overrides.window_background_opacity then
		overrides.window_background_opacity = 1
	else
		overrides.window_background_opacity = nil
	end
	window:set_config_overrides(overrides)
end)

function M.setup(config)
	config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }
	-- config.disable_default_key_bindings = true
	config.hyperlink_rules = wezterm.default_hyperlink_rules()
	config.mouse_bindings = {
		-- Cmd-click to open links
		{
			event = { Up = { streak = 1, button = "Left" } },
			mods = "CMD",
			action = wezterm.action.OpenLinkAtMouseCursor,
		},
	}

	-- https://wezfurlong.org/wezterm/config/lua/keyassignment/index.html
	config.keys = {
		-- Send "CTRL-A" to the terminal when pressing CTRL-A, CTRL-A
		{
			key = "a",
			mods = "LEADER|CTRL",
			action = wezterm.action.SendKey({ key = "a", mods = "CTRL" }),
		},

		-- Session management
		{
			key = "a",
			mods = "LEADER",
			action = wezterm.action.AttachDomain("unix"),
		},
		{
			key = "d",
			mods = "LEADER",
			action = wezterm.action.DetachDomain({ DomainName = "unix" }),
		},

		-- Tab management
		{
			key = "c",
			mods = "LEADER",
			action = wezterm.action({ SpawnTab = "CurrentPaneDomain" }),
		},
		{
			key = "h",
			mods = "CTRL|ALT",
			action = act.ActivateTabRelative(-1),
		},
		{
			key = "l",
			mods = "CTRL|ALT",
			action = act.ActivateTabRelative(1),
		},
		{
			key = "'",
			mods = "LEADER",
			action = act.PromptInputLine({
				description = "Set tab title",
				action = wezterm.action_callback(function(window, pane, line)
					-- line will be `nil` if they hit escape without entering anything
					-- An empty string if they just hit enter
					-- Or the actual line of text they wrote
					if line then
						window:active_tab():set_title(line)
					end
				end),
			}),
		},
		{
			key = "t",
			mods = "LEADER",
			action = wezterm.action.ShowTabNavigator,
		},

		-- Splits
		-- Splits: creation
		{
			key = [[\]],
			mods = "LEADER",
			action = wezterm.action({
				SplitHorizontal = { domain = "CurrentPaneDomain" },
			}),
		},
		{
			key = "v",
			mods = "LEADER",
			action = wezterm.action.SplitPane({
				top_level = true,
				direction = "Right",
				size = { Percent = 50 },
			}),
		},
		{
			key = [[|]],
			mods = "LEADER",
			action = wezterm.action.SplitPane({
				top_level = true,
				direction = "Right",
				size = { Percent = 50 },
			}),
		},
		{
			key = "s",
			mods = "LEADER",
			action = wezterm.action({
				SplitVertical = { domain = "CurrentPaneDomain" },
			}),
		},
		{
			key = [[-]],
			mods = "LEADER",
			action = wezterm.action({
				SplitVertical = { domain = "CurrentPaneDomain" },
			}),
		},
		{
			key = [[_]],
			mods = "LEADER",
			action = wezterm.action.SplitPane({
				top_level = true,
				direction = "Down",
				size = { Percent = 50 },
			}),
		},
		-- Splits: destroy
		{ key = "x", mods = "LEADER", action = wezterm.action.CloseCurrentPane({ confirm = false }) },
		-- Splits: resizing
		{ key = "LeftArrow", mods = "LEADER", action = wezterm.action.AdjustPaneSize({ "Left", 1 }) },
		{ key = "RightArrow", mods = "LEADER", action = wezterm.action.AdjustPaneSize({ "Right", 1 }) },
		{ key = "UpArrow", mods = "LEADER", action = wezterm.action.AdjustPaneSize({ "Up", 1 }) },
		{ key = "DownArrow", mods = "LEADER", action = wezterm.action.AdjustPaneSize({ "Down", 1 }) },

		{
			key = "p",
			mods = "LEADER",
			action = wezterm.action.ActivateCommandPalette,
		},
		{
			key = "`",
			mods = "LEADER",
			action = wezterm.action.ShowLauncherArgs({
				flags = "LAUNCH_MENU_ITEMS|FUZZY|TABS|DOMAINS|WORKSPACES",
			}),
		},
		{
			key = ",",
			mods = "LEADER",
			action = wezterm.action.PromptInputLine({
				description = "Enter new name for workspace",
				action = wezterm.action_callback(function(window, pane, line)
					if line then
						wezterm.mux.rename_workspace(window:mux_window():get_workspace(), line)
					end
				end),
			}),
		},

		{
			key = "q",
			mods = "LEADER",
			action = wezterm.action({ CloseCurrentTab = { confirm = false } }),
		},
		-- TODO: do we need this since we kept the default keybinds?
		{ key = "u", mods = "LEADER", action = wezterm.action.EmitEvent("update-plugins") },
		{ key = "z", mods = "LEADER", action = wezterm.action.TogglePaneZoomState },
		{ key = "y", mods = "LEADER", action = wezterm.action.ActivateCopyMode },
		{ key = "h", mods = "SUPER", action = wezterm.action.HideApplication },
		{ key = "f", mods = "SUPER", action = wezterm.action.Search({ CaseSensitiveString = "" }) },
		{ key = "F12", mods = "", action = wezterm.action.ToggleFullScreen },
	}
	smart_splits.apply_to_config(config, {
		-- direction_keys = {
		-- 	move = { "h", "j", "k", "l" },
		-- 	resize = { "LeftArrow", "DownArrow", "UpArrow", "RightArrow" },
		-- },
	})
end

-- return keys and mouse
return M

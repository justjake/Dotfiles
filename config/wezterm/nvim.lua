local wezterm = require("wezterm")
local M = {}

local function resolve_location(location)
	local pane = location and location.pane
	local tab = pane and pane:tab() or location and location.tab
	local window = tab and tab:window() or location and location.window
	return {
		pane = pane,
		tab = tab,
		window = window,
	}
end

local function find_pane_in_tab(tab, is_match)
	-- TODO: try active pane first
	for _, pane in ipairs(tab:panes()) do
		if is_match(pane) then
			return pane
		end
	end
end

local function find_pane_in_window(window, is_match)
	-- TODO: try active tab
	for _, tab in ipairs(window:tabs()) do
		local res = find_pane_in_tab(tab, is_match)
		if res then
			return res
		end
	end
end

-- Start close to location, find a matching pane.
function M.find_pane(is_match, maybe_location)
	local location = resolve_location(maybe_location)

	if location.pane and is_match(location.pane) then
		return location.pane
	end

	if location.tab then
		local res = find_pane_in_tab(location.tab, is_match)
		if res then
			return res
		end
	end

	if location.window then
		local res = find_pane_in_window(location.window, is_match)
		if res then
			return res
		end
	end

	-- TODO: check on-screen windows first
	for _, any_window in ipairs(wezterm.mux.all_windows()) do
		local res = find_pane_in_window(any_window, is_match)
		if res then
			return res
		end
	end
end

local function is_nvim_pane(pane)
	-- Example process info
	--[[
  {
    "argv": [
        "nvim",
        ".",
    ],
    "children": {
        69443: {
            "argv": [
                "nvim",
                "--embed",
                ".",
            ],
            "children": {
                69835: {
                    "argv": [
                        "/Users/jitl/.local/share/nvim/mason/packages/lua-language-server/libexec/bin/lua-language-server",
                    ],
                    "children": [],
                    "cwd": "/Users/jitl/.dotfiles",
                    "executable": "/Users/jitl/.local/share/nvim/mason/packages/lua-language-server/libexec/bin/lua-language-server",
                    "name": "lua-language-se",
                    "pid": 69835,
                    "ppid": 69443,
                    "start_time": 1735184611,
                    "status": "Run",
                },
            },
            "cwd": "/Users/jitl/.dotfiles/config/wezterm",
            "executable": "/opt/homebrew/Cellar/neovim/0.10.2_1/bin/nvim",
            "name": "nvim",
            "pid": 69443,
            "ppid": 69442,
            "start_time": 1735184609,
            "status": "Run",
        },
    },
    "cwd": "/Users/jitl/.dotfiles/config/wezterm",
    "executable": "/opt/homebrew/bin/nvim",
    "name": "nvim",
    "pid": 69442,
    "ppid": 33753,
    "start_time": 1735184609,
    "status": "Run",
}
  --]]
	local proc = pane:get_foreground_process_info()
	if proc.name == "nvim" then
		return true
	end
	if proc.executable:find("nvim") then
		return true
	end
	if proc.argv[1]:find("nvim") then
		return true
	end
	return false
end

function M.find_nvim_pane(location)
	return M.find_pane(is_nvim_pane, location)
end

function M.edit(args)
	local pane = M.find_nvim_pane(args)
	if pane then
		pane:activate()
		-- TODO: send escape, or use remote control via server
		pane:send_text(":e " .. args.path)
		return true
	end

	-- TODO: spawn new pane running nvim
	return false
end

return M

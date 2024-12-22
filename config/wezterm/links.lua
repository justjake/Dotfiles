-- https://wezfurlong.org/wezterm/config/lua/config/hyperlink_rules.html?h=hyperlink

local wezterm = require("wezterm")
local M = {}

function M.setup(config)
	config.hyperlink_rules = wezterm.default_hyperlink_rules()
	local function rule(defn)
		table.insert(config.hyperlink_rules, defn)
	end

	-- Github Issues: #12345
	-- rule({
	--    regex =
	--  })
end

return M

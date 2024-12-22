-- https://wezfurlong.org/wezterm/config/lua/config/hyperlink_rules.html?h=hyperlink

local wezterm = require("wezterm")
local M = {}

function M.setup(config)
	config.hyperlink_rules = wezterm.default_hyperlink_rules()
	local function rule(defn)
		table.insert(config.hyperlink_rules, defn)
	end

	-- make username/project paths clickable. this implies paths like the following are for github.
	-- ( "nvim-treesitter/nvim-treesitter" | wbthomason/packer.nvim | wez/wezterm | "wez/wezterm.git" )
	-- as long as a full url hyperlink regex exists above this it should not match a full url to
	-- github or gitlab / bitbucket (i.e. https://gitlab.com/user/project.git is still a whole clickable url)
	rule({
		regex = [[["]?([\w\d]{1}[-\w\d]+)(/){1}([-\w\d\.]+)["]?]],
		format = "https://www.github.com/$1/$3",
	})

	-- Github Issues: #12345
	-- Asks `gh pr view --web` to open the PR based on the git repo
	local gh_issue_prefix = "GITHUB_PR:"
	rule({
		regex = [[\#(\d+)]],
		format = gh_issue_prefix .. "$1",
	})
	local default_path = "/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin"
	wezterm.on("open-uri", function(window, pane, uri)
		local start, match_end = uri:find(gh_issue_prefix)
		if start == 1 then
			local number = uri:sub(match_end + 1)
			local cwd = wezterm.shell_quote_arg(pane:get_current_working_dir().file_path)
			-- https://wezfurlong.org/wezterm/config/lua/pane/index.html
			local path_var = pane:get_user_vars().WEZTERM_PATH or default_path
			print("Github PR clicked: cwd" .. cwd .. "PR #" .. number)
			print("PATH=" .. path_var .. " (if this is wrong, set user var WEZTERM_PATH via shell integration)")
			local ok, stdout, stderr = wezterm.run_child_process({
				"env",
				"PATH=" .. path_var,
				"sh",
				"-c",
				"cd " .. cwd .. " && gh pr view --web " .. number,
			})
			print("URL Handler: Github PR command ok? " .. tostring(ok))
			print("URL Handler: stdout:\n" .. stdout)
			print("URL Handler: stderr:\n" .. stderr)

			if not ok then
				-- This didn't do anything :(
				-- TODO: we could show a prompt or inject text instead...
				window:toast_notification("Github PR Error", stdout .. stderr)
			end

			-- prevent the default action from opening in a browser
			return false
		end
		-- otherwise, by not specifying a return value, we allow later
		-- handlers and ultimately the default action to caused the
		-- URI to be opened in the browser
	end)
end

return M

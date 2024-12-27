-- https://wezfurlong.org/wezterm/config/lua/config/hyperlink_rules.html?h=hyperlink

local wezterm = require("wezterm")
local nvim = require("nvim")
local M = {}

local line_param = "?line="
local column_param = "&column="

local function get_uri_body(protocol, uri)
	local start, match_end = uri:find(protocol)
	if start == 1 then
		return uri:sub(match_end + 1)
	end
end

local function get_uri_line_column(protocol, uri)
	local path_and_params = get_uri_body(protocol, uri)
	if path_and_params == nil then
		return nil
	end

	local line_param_start, line_param_end = path_and_params:find(line_param)
	if not type(line_param_start) == "number" then
		error("expected to find " .. line_param)
	end
	local column_param_start, column_param_end = path_and_params:find(column_param, line_param_end)
	if not type(column_param_start) == "number" then
		error("expected to find" .. column_param)
	end

	local path = path_and_params:sub(1, line_param_start - 1)
	local line = path_and_params:sub(line_param_end + 1, column_param_start - 1)
	local column = path_and_params:sub(column_param_end + 1)
	local result = {
		path = path,
		line = line ~= "" and line or nil,
		column = column ~= "" and column or nil,
	}

	print("get_uri_line_column:", {
		uri = uri,
		protocol = protocol,
		result = result,
	})

	return result
end

local default_path = "/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin"
local function run_child_with_pane_path(pane, argv)
	if type(argv) == "string" then
		argv = { "sh", "-c", argv }
	end

	-- https://wezfurlong.org/wezterm/config/lua/pane/index.html
	local cwd = wezterm.shell_quote_arg(pane:get_current_working_dir().file_path)
	local path_var = pane:get_user_vars().WEZTERM_PATH or default_path

	local env_argv = {
		"env",
		"PATH=" .. path_var,
		"PWD=" .. cwd,
		"bash",
		"-c",
		[[cd "$PWD" && exec "$@"]],
		"run_child_with_pane_path", -- $0, used in error messages
		table.unpack(argv), -- becomes $@
	}
	local ok, stdout, stderr = wezterm.run_child_process(env_argv)
	print("run_child_with_pane_path:", env_argv, "result:", { ok = ok, stdout = stdout, stderr = stderr })
	return ok, stdout, stderr
end

-- Code from discussion: https://github.com/wez/wezterm/discussions/529

-- Use some simple heuristics to determine if we should open it
-- with a text editor in the terminal.
-- Take note! The code in this file runs on your local machine,
-- but a URI can appear for a remote, multiplexed session.
-- WezTerm can spawn the editor in that remote session, but doesn't
-- have access to the file locally, so we can't probe inside the
-- file itself, so we are limited to simple heuristics based on
-- the filename appearance.
function is_editable(filename)
	-- "foo.bar" -> ".bar"
	local extension = filename:match("^.+(%..+)$")
	if extension then
		-- ".bar" -> "bar"
		extension = extension:sub(2)
		wezterm.log_info(string.format("is_editable: extension is [%s]", extension))
		local binary_extensions = {
			jpg = true,
			jpeg = true,
			png = true,
			hef = true,
			-- TODO: add more
			-- TODO: shell out to `file $1 | grep text`
		}
		if binary_extensions[extension:lower()] then
			-- can't edit binary files
			return false
		end
	end

	-- if there is no, or an unknown, extension, then assume
	-- that our trusty editor will do something reasonable

	return true
end

local function get_file_uri_path(uri)
	-- `file://hostname/path/to/file`
	local start, match_end = uri:find("file:")
	if start == 1 then
		-- skip "file://", -> `hostname/path/to/file`
		local host_and_path = uri:sub(match_end + 3)
		local start, match_end = host_and_path:find("/")
		if start then
			-- -> `/path/to/file`
			return host_and_path:sub(match_end)
		end
	end

	return nil
end

function M.setup(config)
	config.hyperlink_rules = wezterm.default_hyperlink_rules()
	local uri_handlers = {}

	local function rule(defn)
		print("links: add rule", defn)
		table.insert(config.hyperlink_rules, {
			regex = defn.regex,
			format = defn.format,
			highlight = defn.highlight,
		})
		if defn.handler then
			table.insert(uri_handlers, defn.handler)
		end
	end

	local boundary_characters = [[\s'"\[\]\(\):]]
	local boundary_class = "[" .. boundary_characters .. "]"
	local not_boundary_class = "[^" .. boundary_characters .. "]"
	local number_group = [[(?::(\d+))]]
	local path_group = "(/" .. not_boundary_class .. "+)"

	-- NodeJS internal modules, node: protocol
	local node_protocol = "node:"
	rule({
		regex = boundary_class
			.. "?(("
			.. node_protocol
			.. not_boundary_class
			.. "+)"
			.. number_group
			.. "?"
			.. number_group
			.. "?)"
			.. boundary_class
			.. "?",
		format = node_protocol .. "$2" .. line_param .. "$3" .. column_param .. "$4",
		handler = function(window, pane, uri)
			local file_and_line = get_uri_line_column(node_protocol, uri)
			if file_and_line == nil then
				return nil
			end

			-- Shell out to node to find appropriate version of file
			local resolve_url_script = [[(() => {
let importTarget = process.argv[1]
try { importTarget = require.resolve(importTarget) } catch {}
if (importTarget.startsWith('/')) {
  return `file://${importTarget}`
}
importTarget = importTarget.replace(/^node:/, '')
importTarget = importTarget.match(/\.js(\w)?$/) ?
  importTarget :
  importTarget + ".js"
return `https://github.com/nodejs/node/blob/${process.version}/lib/${importTarget}`
})()]]
			local ok, stdout, stderr = run_child_with_pane_path(pane, {
				"node",
				"-p",
				resolve_url_script,
				"--",
				file_and_line.path,
			})

			if not ok then
				error("node protocol error:" .. stderr)
				return false
			end

			-- https://wezfurlong.org/wezterm/config/lua/wezterm.url/Url.html
			local resolved_uri = stdout:gsub("^%s*(.-)%s*$", "%1")
			local resolved_url = wezterm.url.parse(resolved_uri)
			if resolved_url.scheme == "file" then
				nvim.edit({
					path = resolved_url.file_path,
					line = file_and_line.line,
					column = file_and_line.column,
					pane = pane,
				})
			else
				if resolved_url.scheme == "https" then
					wezterm.run_child_process({ "open", resolved_uri .. "#L" .. file_and_line.line })
				else
					error("unexpected scheme resolved by node: " .. resolved_uri)
				end
			end
			return false
		end,
	})

	-- File paths, some examples:
	--[[ 
/Users/jitl/.dotfiles/zsh/rc.d/21_cs61b.zsh:8: command not found: hostname
/Users/jitl/.dotfiles/zsh/rc.d/21_rescomp.zsh:3: command not found: hostname
/Users/jitl/.dotfiles/zsh/rc.d/21_rescomp.zsh:3: command not found: hostname
/Users/jitl/.dotfiles/zsh/hosts/Mac.zsh:5: command not found: rbenv
/Users/jitl/.dotfiles/zsh/hosts/Mac.zsh:6: command not found: direnv
(node:61252) [DEP0040] DeprecationWarning: The `punycode` module is deprecated. Please use a userland alternative instead.
    at node:punycode:3:9
    at BuiltinModule.compileForInternalLoader (node:internal/bootstrap/realm:399:7)
    at BuiltinModule.compileForPublicLoader (node:internal/bootstrap/realm:338:10)
    at loadBuiltinModule (node:internal/modules/helpers:110:7)
    at Function._load (node:internal/modules/cjs/loader:1091:17)
    at TracingChannel.traceSync (node:diagnostics_channel:322:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:220:24)
    at Module.<anonymous> (node:internal/modules/cjs/loader:1327:12)
    at require (node:internal/modules/helpers:136:16)
    at Object.<anonymous> (/Users/jitl/src/notion/node_modules/gaxios/node_modules/whatwg-url/lib/url-state-machine.js:2:18)
    at Module.<anonymous> (node:internal/modules/cjs/loader:1566:14)
--]]
	-- TODO: do.
	-- Example: https://github.com/wez/wezterm/discussions/529
	-- Default URL rules: `wezterm.default_hyperlink_rules()`
	local editor_prefix = "EDITOR:"
	rule({
		regex = boundary_class
			.. "?("
			.. path_group
			.. number_group
			.. "?"
			.. number_group
			.. "?)"
			.. boundary_class
			.. "?",
		format = editor_prefix .. "$2" .. line_param .. "$3" .. column_param .. "$4",
		highlight = 1,
		handler = function(window, pane, uri)
			local file_and_line = get_uri_line_column(editor_prefix, uri)
			if file_and_line == nil then
				return nil
			end
			if file_and_line.line or is_editable(file_and_line.path) then
				local did_edit = nvim.edit({
					path = file_and_line.path,
					line = file_and_line.line,
					column = file_and_line.column,
					pane = pane,
				})
				if did_edit then
					return false
				end
			end

			-- Fall back to OS open
			wezterm.run_child_process({
				"open",
				path,
			})
			return false
		end,
	})

	-- make username/project paths clickable. this implies paths like the following are for github.
	-- ( "nvim-treesitter/nvim-treesitter" | wbthomason/packer.nvim | wez/wezterm | "wez/wezterm.git" )
	-- as long as a full url hyperlink regex exists above this it should not match a full url to
	-- github or gitlab / bitbucket (i.e. https://gitlab.com/user/project.git is still a whole clickable url)
	--
	-- rule({
	-- 	regex = [[\b["']?([\w\d]{1}[-\w\d]+)(/){1}([-\w\d\.]+)["']?]],
	-- 	format = "https://www.github.com/$1/$3",
	-- })

	-- Github Issues: #12345
	-- Asks `gh pr view --web` to open the PR based on the git repo
	local gh_issue_prefix = "GITHUB_PR:"
	rule({
		regex = [[\#(\d+)]],
		format = gh_issue_prefix .. "$1",
	})
	local function open_github_issue_uri(window, pane, uri)
		local start, match_end = uri:find(gh_issue_prefix)
		if start == 1 then
			local number = uri:sub(match_end + 1)
			local ok, stdout, stderr = run_child_with_pane_path(pane, "gh pr view --web " .. number)
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
	end

	wezterm.on("open-uri", function(window, pane, uri)
		for _, handler in ipairs(uri_handlers) do
			local result = handler(window, pane, uri)
			if result ~= nil then
				return result
			end
		end
	end)
end

return M

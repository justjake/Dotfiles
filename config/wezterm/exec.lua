local wezterm = require("wezterm")

local M = {}

local default_path = "/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin"

local function to_argv(argv)
	if type(argv) == "string" then
		argv = { "sh", "-c", argv }
	end
	return argv
end

local function chomp_newline(string)
	if string:sub(-1) == "\n" then
		return string:sub(1, -2)
	else
		return string
	end
end

function M.pane_command(pane, argv)
	local cwd = wezterm.shell_quote_arg(pane:get_current_working_dir().file_path)
	local path_var = pane:get_user_vars().WEZTERM_PATH or default_path
	return {
		"env",
		"PATH=" .. path_var,
		"CWD=" .. cwd, -- bash overrides $PWD so we cant use it
		"bash",
		"-c",
		[[cd "$CWD" && exec "$@"]],
		"exec.pane_command", -- $0, used in error messages
		table.unpack(to_argv(argv)), -- becomes $@
	}
end

function M.zsh_split_command(argv)
	local script = [[
source ~/.zshrc
"$@"
exit_code=$?
if [ $exit_code != 0 ]; then
  echo "+" "$@"
  echo "exec.zsh_split_command: exited $exit_code"
  echo "sleeping for 30s, press ctrl^c to close"
  sleep 30
  exit $exit_code
fi
]]
	return { "zsh", "-c", script, "exec.zsh_split_command", table.unpack(to_argv(argv)) }
end

function M.ok_stdout_stderr(argv)
	local ok, stdout, stderr = wezterm.run_child_process(to_argv(argv))
	return ok, chomp_newline(stdout), chomp_newline(stderr)
end

function M.stdout(argv)
	argv = to_argv(argv)
	local ok, stdout, stderr = M.ok_stdout_stderr(argv)
	if not ok then
		error("exec: command failed:" .. wezterm.shell_join_args(argv) .. ":\n" .. stderr)
	end
	return stdout
end

function M.pane_stdout(pane, argv)
	return M.stdout(M.pane_command(pane, argv))
end

function M.open(path)
	return M.stdout({ "open", path })
end

return M

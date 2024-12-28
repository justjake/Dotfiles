local base64 = require("util.base64")

local M = {}

-- Translated from smart-splits code by Claude
-- https://github.com/mrjones2014/smart-splits.nvim/blob/master/autoload/smart_splits.vim
local function write_to_stderr(string)
  -- Check if /dev/fd/2 is writable
  local success
  if vim.fn.filewritable("/dev/fd/2") == 1 then
    -- writefile returns 0 on success
    success = vim.fn.writefile({ string }, "/dev/fd/2", "b") == 0
  else
    -- Write directly to stderr using io.stderr
    success = io.stderr:write(string) and true or false
  end
  return success
end

local ESC = string.char(0x1b)
local BEL = string.char(0x07)
local format = ESC .. "]1337;SetUserVar=%s=%s" .. BEL

local function format_var(name, value)
  return string.format(format, name, base64.encode(value))
end

function M.set_var(name, value)
  local formatted = format_var(name, value)
  local ok = write_to_stderr(formatted)
  if not ok then
    vim.print(string.format("wezterm.set_var %s=%s failed", name, value))
  end
end

local function iterate_windows()
  return coroutine.wrap(function()
    local tab_pages = vim.api.nvim_list_tabpages()
    for _, tab in ipairs(tab_pages) do
      local windows = vim.api.nvim_tabpage_list_wins(tab)
      for _, window in ipairs(windows) do
        local buf = vim.api.nvim_win_get_buf(window)
        local filename = vim.api.nvim_buf_get_name(buf)
        local buflisted = vim.api.nvim_buf_get_option(buf, "buflisted")
        coroutine.yield({ tab = tab, window = window, buf = buf, filename = filename, buflisted = buflisted })
      end
    end
  end)
end

local function var_is_falsy(string)
  return string == nil or string == "" or string == "false" or string == "0"
end

local function var_is_truthy(string)
  return not var_is_falsy(string)
end

-- Integrate with Wezterm so we can open files from cmd-click in wezterm
-- This function will be called with the various arguments
function M.drop(filename, line, column)
  -- vim.print("wezterm.drop:", filename, line or "<nil>", column or "<nil>")

  -- If we have an existing buffer for this file, we can use :drop to focus it
  for split in iterate_windows() do
    if split.filename == filename and split.buflisted then
      vim.cmd.drop(filename)
      if var_is_truthy(line) then
        vim.call("cursor", line, var_is_truthy(column) and column or 0)
      end
      return true
    end
  end

  vim.api.nvim_cmd({
    cmd = "vsplit",
    args = { filename },
    mods = {
      -- Open full-height as the rightmost split
      -- https://vimhelp.org/windows.txt.html#%3Atopleft
      vertical = true,
      split = "botright",
    },
  }, {})
  if var_is_truthy(line) then
    vim.call("cursor", line, var_is_truthy(column) and column or 0)
  end
  return false
end

return M

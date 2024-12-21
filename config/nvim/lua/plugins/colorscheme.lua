-- Customizes base16-circus
-- References:
-- Lua version: https://github.com/RRethy/base16-nvim/blob/master/lua/base16-colorscheme.lua#L146
--              https://github.com/RRethy/base16-nvim/blob/master/lua/colors/circus.lua
-- Vim version: https://github.com/chriskempson/base16-vim/blob/master/colors/base16-circus.vim
local jake_circus = function()
  vim.cmd([[ colorscheme base16-circus ]])

  local M = require("base16-colorscheme")
  local hi = M.highlight

  -- for reference
  ---@diagnostic disable-next-line: unused-local
  local circus = {
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

  local thick = false
  local color = M.colors.base02
  local termcolor = M.colors.cterm02
  hi.WinSeparator = {
    guifg = color,
    guibg = thick and color or nil,
    gui = "none",
    guisp = nil,
    ctermfg = termcolor,
    ctermbg = thick and termcolor or nil,
  }

  hi.NeoTreeGitUntraced = {
    guifg = M.colors.base0B,
  }

  -- with popup_border_style = "rounded"
  hi.NeoTreeFloatBorder = {
    guifg = M.colors.base02,
  }
  hi.NeoTreeTitleBar = {
    guibg = M.colors.base03,
  }
end

-- https://lazy.folke.io/spec
return {
  {
    "RRethy/base16-nvim",
    main = "base16-colorscheme",
    lazy = false,
    priority = 1000,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = jake_circus,
    },
  },
}

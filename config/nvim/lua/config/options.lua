-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
local opt = vim.opt

-- Disable system clipboard integration
-- I really value vim yank being seperate from cmd-c cmd-v
-- because i treat system copy paste as importat!
opt.clipboard = ""

-- Customize some hard-to-read error colors (not necessary under LazyVim?)
-- vim.cmd([[hi SpellBad           ctermfg=7 ctermbg=9]])
-- vim.cmd([[hi NvimInternalError  ctermfg=7 ctermbg=9]])

opt.fillchars = vim.tbl_extend("force", opt.fillchars:get(), {
  -- vert = " ",
})
opt.number = true
opt.relativenumber = false
opt.ruler = true
opt.showmatch = true
-- highlight current line
opt.cursorline = true -- highlight current line
-- Draw right-hand ruler at 100 chars
opt.colorcolumn = "100"
-- colorcolumn color
-- vim.cmd([[highlight ColorColumn ctermbg=238]])

-- don't add an extra space when joining punctuation like .?! (default in nvim)
-- opt.joinspaces = false

-- search
opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true

-- indenting. don't get crazy
opt.autoindent = true

-- nvim has sensible defaults for this now.
-- (also, we need to expand the path; ~ is literal)
-- opt.backupdir = "~/.vim/_backup"
-- opt.dir = "~/.vim/_temp,/var/tmp,/tmp"

-- opening buffers: open in a split. investiage tabs
opt.switchbuf = "usetab,vsplit"

-- splits
opt.equalalways = true

-- Wrap lines at word boundaries and make the wrapping more obvious.
opt.wrap = true
opt.showbreak = ".."
opt.breakindent = true
opt.breakindentopt = "shift:2,sbr"

-- NOTE: LazyVim fixes {{{
-- Disable crazy animations
vim.g.snacks_animate = false

-- Disable confusing "-" in trailing spaces
-- Perhaps other themes have good styling
opt.listchars = "tab:> ,nbsp:+"
-- NOTE: End LazyVim fixes }}}

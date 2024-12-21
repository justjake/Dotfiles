-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Disable crazy animations
vim.g.snacks_animate = false

local opt = vim.opt
opt.relativenumber = false
opt.wrap = true

-- Disable system clipboard integration
-- I really value vim yank being seperate from cmd-c cmd-v
-- because i treat system copy paste as importat!
opt.clipboard = ""

-- Disable confusing "-" in trailing spaces
-- Perhaps other themes have good styling
opt.listchars = "tab:> ,nbsp:+"

opt.fillchars = vim.tbl_extend("force", opt.fillchars:get(), {
  vert = " ",
})
opt.number = true
opt.ruler = true
opt.showmatch = true
opt.colorcolumn = "100" -- Draw right-hand ruler at 100 chars
vim.cmd([[highlight ColorColumn ctermbg=238]])
opt.cursorline = true -- highlight current line

-- don't add an extra space when joining punctuation like .?!
opt.nojoinspaces = true

-- search
opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true

-- indenting. don't get crazy
opt.autoindent = true

-- backups: don't fuck up my local directories
opt.backupdir = "~/.vim/_backup"
opt.dir = "~/.vim/_temp,/var/tmp,/tmp"

-- opening buffers: open in a split. investiage tabs
opt.switchbuf = "usetab,vsplit"

-- splits
opt.equalalways = true

-- Wrap lines at word boundaries and make the wrapping more obvious.
opt.showbreak = ".."
opt.breakindent = true
opt.breakindentopt = "shift:2,sbr"

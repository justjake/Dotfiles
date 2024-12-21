-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Git commits wrap at 72
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "gitcommit" },
  callback = function()
    -- LazyVim already sets spell, wrap.
    vim.opt_local.textwidth = 72
  end,
})

-- Notion uses tabs
-- au BufRead,BufEnter /Users/jitl/src/notion/*.{js,ts,tsx,json} set ts=2 sw=2 noet
vim.api.nvim_create_autocmd({ "BufRead", "BufEnter" }, {
  pattern = "/Users/jitl/src/notion/*.{js,ts,tsx,json}",
  callback = function()
    vim.opt_local.expandtab = false
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
  end,
})

-- TODO: strip trailing whitespace globally
--
-- " strip trailing whitespace
-- fun! StripTrailingWhitespace()
--     " Only strip if the b:noStripWhitespace variable isn't set
--     if exists('b:noStripWhitespace')
--         return
--     endif
--     if getline(1) =~ "noStripWhitespace"
--         return
--     endif
--
--     exe "normal mz"
--     %s/\s\+$//ge
--     exe "normal `z"
-- endfun
-- autocmd BufWritePre * call StripTrailingWhitespace()
-- autocmd FileType markdown let b:noStripWhitespace=1

-- TODO: Check if tsconfig.json still misconfigured w/ LazyVim
--
-- " tsconfig.json is actually jsonc, help TypeScript set the correct filetype
-- autocmd BufRead,BufNewFile tsconfig.json set filetype=jsonc
-- autocmd BufRead,BufNewFile *tsconfig.json set filetype=jsonc
-- au BufRead,BufNewFile *.dl             set filetype=dl

-- NOTE: Coc bindings to manage the file navigator, not neccessary under LazyVim
--
-- autocmd BufEnter * if (winnr("$") == 1 && &filetype == 'coc-explorer') | q | endif
--
-- function! AuCocExplorerAutoOpen()
--     " Move focus back after opening the explorer this time.
--     autocmd User CocExplorerOpenPost ++once exe ':wincmd p'
--     " Now open the explorer
--     exe ':CocCommand explorer --no-toggle'
-- endfunction
--
--
-- function! AuCocExplorerCloseLast()
--   if (winnr("$") == 1)
--     quit
--   endif
-- endfunction
--
-- autocmd User CocNvimInit call AuCocExplorerAutoOpen()
-- autocmd User CocExplorerOpenPost call AuCocExplorerCloseLast()

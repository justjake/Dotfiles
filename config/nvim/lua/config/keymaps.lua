-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
local map = vim.keymap.set

-- vim-tmux-navigtor evolved keymaps. smart-splits integrates with wezterm
--
-- moving between splits
vim.keymap.set("n", "<C-h>", require("smart-splits").move_cursor_left, { desc = "Pane or window left" })
vim.keymap.set("n", "<C-j>", require("smart-splits").move_cursor_down, { desc = "Pane or window down" })
vim.keymap.set("n", "<C-k>", require("smart-splits").move_cursor_up, { desc = "Pane or window up" })
vim.keymap.set("n", "<C-l>", require("smart-splits").move_cursor_right, { desc = "Pane or window right" })
vim.keymap.set("n", "<C-\\>", require("smart-splits").move_cursor_previous, { desc = "Previous Pane or window" })
-- resizing splits
vim.keymap.set("n", "<A-h>", require("smart-splits").resize_left, { desc = "Resize left" })
vim.keymap.set("n", "<A-j>", require("smart-splits").resize_down, { desc = "Resize down" })
vim.keymap.set("n", "<A-k>", require("smart-splits").resize_up, { desc = "Resize up" })
vim.keymap.set("n", "<A-l>", require("smart-splits").resize_right, { desc = "Resize right" })
-- swapping buffers between windows
vim.keymap.set("n", "<leader><leader>h", require("smart-splits").swap_buf_left, { desc = "Swap buffer left" })
vim.keymap.set("n", "<leader><leader>j", require("smart-splits").swap_buf_down, { desc = "Swap buffer down" })
vim.keymap.set("n", "<leader><leader>k", require("smart-splits").swap_buf_up, { desc = "Swap buffer up" })
vim.keymap.set("n", "<leader><leader>l", require("smart-splits").swap_buf_right, { desc = "Swap buffer right" })
--

-- copy-paste from system keyboard with leader-{y,p}
-- vmap <Leader>y "+y
-- vmap <Leader>Y "+Y
-- nmap <Leader>y "+y
-- nmap <Leader>Y "+Y
map({ "v", "n" }, "<Leader>y", '"+y', { desc = "Copy to system clipboard" })
map({ "v", "n" }, "<Leader>Y", '"+Y', { desc = "Copy to system clipboard (before)" })

-- vmap <Leader>p "+p
-- vmap <Leader>P "+P
-- nmap <Leader>p "+p
-- nmap <Leader>P "+P
map({ "v", "n" }, "<Leader>p", '"+p', { desc = "Paste from system clipboard" })
map({ "v", "n" }, "<Leader>P", '"+P', { desc = "Paste from system clipboard (before)" })

-- " Reselect visual block after indent/outdent (noremap may be the default and unnecessary)
-- vnoremap < <gv
-- vnoremap > >gv
map("v", "<", "<gv", { noremap = true })
map("v", ">", ">gv", { noremap = true })

-- " mapping to make movements operate on 1 screen line in wrap mode
-- function! ScreenMovement(movement)
--    if &wrap
--       return "g" . a:movement
--    else
--       return a:movement
--    endif
-- endfunction
-- onoremap <silent> <expr> j ScreenMovement("j")
-- onoremap <silent> <expr> k ScreenMovement("k")
-- onoremap <silent> <expr> 0 ScreenMovement("0")
-- onoremap <silent> <expr> ^ ScreenMovement("^")
-- onoremap <silent> <expr> $ ScreenMovement("$")
-- nnoremap <silent> <expr> j ScreenMovement("j")
-- nnoremap <silent> <expr> k ScreenMovement("k")
-- nnoremap <silent> <expr> 0 ScreenMovement("0")
-- nnoremap <silent> <expr> ^ ScreenMovement("^")
-- nnoremap <silent> <expr> $ ScreenMovement("$")
--
-- Test it here with :set wrap
-- ==================================================================================================================
local movements = { "j", "k", "0", "^", "$" }
for _, movement in ipairs(movements) do
  map({ "n", "o" }, movement, function()
    if vim.o.wrap then
      return "g" .. movement
    else
      return movement
    end
  end, { expr = true })
end

-- TODO: port these to LazyVim/Lua.
-- LazyVim <space><space> to fuzzy-open replaces some.
--
-- " leader-related bindings
-- nnoremap <leader>f :ProjectFiles<CR>
-- nnoremap <leader>fn :ProjectNodeModules<CR>
-- nnoremap <Leader>w :w<CR>
-- " nnoremap <Leader>g :NERDTreeFind<CR>

-- NOTE: LazyVim tree automatically focuses the current buf,
-- so this is probably unnecessary to port. Retaining for reference.
--
-- function! ExploreHere()
--   " Ensure the explorer is open
--   exe ':CocCommand explorer --no-toggle --no-focus'
--   " Reveal the current file in the explorer
--   call CocAction('runCommand', 'explorer.doAction', 'closest', ['reveal:0'], [['relative', 0, 'file']])
--   " Focus the explorer
--   exe ':CocCommand explorer --no-toggle --focus'
-- endfunction
-- nnoremap <Leader>g :call ExploreHere()<CR>

vim.keymap.set({ "i", "n" }, "<MouseMove>", require("hover").hover_mouse, { desc = "hover.nvim (mouse)" })
vim.o.mousemoveevent = true

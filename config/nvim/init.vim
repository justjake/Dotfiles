"
"
"  .d8888888b.   d8b d8b 888    888 d8b                            d8b
" d88P'   'Y88b  Y8P Y8P 888    888 88P                            Y8P
" 888  d8b  888          888    888 8P
" 888  888  888 8888 888 888888 888 ' .d8888b    88888b.  888  888 888 88888b.d88b.
" 888  888bd88P '888 888 888    888   88K        888 '88b 888  888 888 888 '888 '88b
" 888  Y8888P'   888 888 888    888   'Y8888b.   888  888 Y88  88P 888 888  888  888
" Y88b.     .d8  888 888 Y88b.  888        X88   888  888  Y8bd8P  888 888  888  888
"  'Y88888888P'  888 888  'Y888 888    88888P'   888  888   Y88P   888 888  888  888
"                888
"               d88P
"             888P'
"
"             written for...
"             os version:   FreeBSD 10.2-RELEASE-p18 (jailed)
"             nvim version: NVIM v0.2.0-577-g30826cb2 (make CMAKE_BUILD_TYPE=RelWithDebInfo)
"
" TODOs:
" - unite seems cool, conf here: https://github.com/Xuyuanp/vimrc/blob/master/vundles/unite.vim
" - should probably do syntastic at some point, but flycheck in emacs left a
"   bad taste in my mouth
" - should restrict vim commit width to 60 or whatever to make Github pretty
let mapleader="\<Space>"

" auto-install plugin manager
if !filereadable(expand('~/.config/nvim/autoload/plug.vim'))
  !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
endif

" auto-patch terminfo so that ctrl-h works
silent !sh ~/.config/nvim/patch-terminfo-for-vim-tmux-navigator.sh

" Uncomment this line for true color in your Nvim, although this makes zenburn
" look odd. Requires tmux 2.2+ and a good emulator like iTerm2.
"set termguicolors

" plugins {{{
call plug#begin('~/.config/nvim/plug')

" linting
Plug 'w0rp/ale'

" visual widgets
Plug 'scrooloose/nerdtree' | Plug 'jistr/vim-nerdtree-tabs' " file browsing sidebar thing
Plug 'Xuyuanp/nerdtree-git-plugin'
  " TODO: figure out why &columns gives 80 on startup
  let g:nerdtree_tabs_open_on_console_startup=1
  let NERDTreeShowHidden=1

Plug 'ctrlpvim/ctrlp.vim'                  " fuzzy file opener
  " search files + buffers + MRU
  let g:ctrlp_cmd = 'CtrlPMixed'
  " use ag for CtrlP
  if executable('ag')
    " use ag to list files - nice because fast and .gitignore support
    let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
    " ag fast, don't need cache
    let g:ctrlp_use_caching = 0
  endif

Plug 'airblade/vim-gitgutter'          " show git line status in gutter
Plug 'vim-airline/vim-airline'               " nifty vim statusline
  let g:airline#extensions#ale#enabled = 1
"  let g:airline#extensions#tabline#enabled = 1

" completion - https://gregjs.com/vim/2016/configuring-the-deoplete-asynchronous-keyword-completion-plugin-with-tern-for-vim/
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' } " completion bepis for NeoVim
  let g:deoplete#enable_at_startup = 1
  if !exists('g:deoplete#omni#input_patterns')
    let g:deoplete#omni#input_patterns = {}
  endif
  " auto-close the scratch window sometimes shown for completions at screen bottom
  autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif
Plug 'ervandew/supertab'               " complete using <TAB>
  let g:SuperTabDefaultCompletionType = "<c-n>"
Plug 'racer-rust/vim-racer'            " needs `cargo install racer` and RUST_SRC_PATH
  let g:racer_cmd="racer"

" visual style
Plug 'jnurmine/Zenburn'                " the best color scheme ever made
Plug 'luochen1990/rainbow'           " rainbow parens
  let g:rainbow_active = 1
  let g:rainbow_conf = {
  \   'ctermfgs': ['4', '3', '12', '8', '10', '5'],
  \}
Plug 'google/vim-colorscheme-primary'
Plug 'NLKNguyen/papercolor-theme'

" controls
Plug 'christoomey/vim-tmux-navigator'  " ctrl + HJKL to navigate vim & tmux splits
Plug 'Raimondi/delimitMate'            " paren matching. Shift-tab to jump out of delim,
                                       "   ctrl-c+thing to avoid
Plug 'tpope/vim-endwise'               " auto do..end in Ruby, etc

" commands
Plug 'tpope/vim-fugitive'              " :Gstatus, :Gedit, :Gdiff, :Glog, etc

" automatic typo correction
Plug 'tpope/vim-abolish' | Plug 'jdelkins/vim-correction'
  let g:abolish_save_file = expand("~/.config/nvim/after/plugin/abolish.vim")
" :Subvert/address{,es}/reference{,s}/g
" :Abolish {despa,sepe}rat{e,es,ed,ing,ely,ion,ions,or}  {despe,sepa}rat{}
" crs (coerce to snake_case). MixedCase (crm), camelCase (crc), snake_case (crs), and UPPER_CASE (cru)

Plug 'rizzatti/dash.vim'               " :Dash
  nmap <silent> <leader>d <Plug>DashSearch

" motions
Plug 'scrooloose/nerdcommenter'        " leader c{c,u} to comment/uncomment
  " control-/ to toggle commenting on a line
  vmap <C-_> <plug>NERDCommenterToggle
  nmap <C-_> <plug>NERDCommenterToggle
  imap <C-_> <plug>NERDCommenterInsert
Plug 'Lokaltog/vim-easymotion'         " press leader-leader then motion

" snippets. this is new, and maybe should be disabled until the user is ready.
Plug 'SirVer/ultisnips'                " snippets engine
Plug 'honza/vim-snippets'              " snippets library

" filetypes
Plug 'sheerun/vim-polyglot'            " many languages
  let g:jsx_ext_required = 0           " in js files, too

Plug 'fatih/vim-go'                    " golang
"Plug 'nsf/gocode', { 'rtp': 'nvim', 'do': 'nvim/symlink.sh' }
Plug 'zchee/deoplete-go', { 'do': 'make' }

call plug#end()

" vim-abolish settings
" }}} end plugins

set encoding=utf-8
scriptencoding utf-8

" appearance
set t_Co=256
syntax on
set background=dark
"set background=light
"colorscheme PaperColor
 colors zenburn               " aaaaaand activate

set fillchars+=vert:\                  " (space after backslash) remove vertical pipe chars from window boundries
set number
set ruler
set showmatch
set colorcolumn=100
highlight ColorColumn ctermbg=238
set cursorline                         " highlight current line


" Tabs. May be overriten by autocmd rules
set tabstop=2
set softtabstop=0
set shiftwidth=2
set expandtab
set smarttab

" don't add an extra space when joining punctuation like .?!
set nojoinspaces

" search
set ignorecase
set smartcase
set incsearch

" indenting. don't get crazy
set autoindent

" backups: don't fuck up my local directories
set backupdir=~/.vim/_backup
set dir=~/.vim/_temp,/var/tmp,/tmp

" opening buffers: open in a split. investiage tabs
set switchbuf=usetab,vsplit

" splits: split right, split below, instead of splitting left,above
" set splitright
" set splitbelow
set equalalways

" leader-related bindings
nnoremap <leader>f :CtrlP<CR>
nnoremap <Leader>w :w<CR>
nnoremap <Leader>g :NERDTreeFind<CR>

" copy-paste from system keyboard with leader-{y,p}
vmap <Leader>y "+y
vmap <Leader>Y "+Y

vmap <Leader>p "+p
vmap <Leader>P "+P

nmap <Leader>p "+p
nmap <Leader>P "+P

nmap <Leader>y "+y
nmap <Leader>Y "+Y

" Reselect visual block after indent/outdent
vnoremap < <gv
vnoremap > >gv

" resize splits with arrow keys
nnoremap <Up> <C-w>+
nnoremap <Down> <C-w>-
nnoremap <Left> <C-w><
nnoremap <Right> <C-w>>

" mapping to make movements operate on 1 screen line in wrap mode
function! ScreenMovement(movement)
   if &wrap
      return "g" . a:movement
   else
      return a:movement
   endif
endfunction
onoremap <silent> <expr> j ScreenMovement("j")
onoremap <silent> <expr> k ScreenMovement("k")
onoremap <silent> <expr> 0 ScreenMovement("0")
onoremap <silent> <expr> ^ ScreenMovement("^")
onoremap <silent> <expr> $ ScreenMovement("$")
nnoremap <silent> <expr> j ScreenMovement("j")
nnoremap <silent> <expr> k ScreenMovement("k")
nnoremap <silent> <expr> 0 ScreenMovement("0")
nnoremap <silent> <expr> ^ ScreenMovement("^")
nnoremap <silent> <expr> $ ScreenMovement("$")

" mouse stuff
" faster drawing is better for scroll wheels
set ttyfast
" enable mouse stuff
set mouse=a
"set ttymouse=xterm2

" filetype customization {{{
autocmd Filetype gitcommit setlocal spell textwidth=72
" }}}

" strip trailing whitespace
fun! StripTrailingWhitespace()
    " Only strip if the b:noStripWhitespace variable isn't set
    if exists('b:noStripWhitespace')
        return
    endif
    %s/\s\+$//e
endfun

autocmd BufWritePre * call StripTrailingWhitespace()
autocmd FileType markdown let b:noStripWhitespace=1

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
"             nvim version: NVIM v0.1.5-560-ga535868 (make CMAKE_BUILD_TYPE=RelWithDebInfo)

" auto-install plugin manager
if !filereadable(expand('~/.config/nvim/autoload/plug.vim'))
  !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
endif

" plugins {{{
call plug#begin('~/.config/nvim/plug')

" visual widgets
Plug 'scrooloose/nerdtree' | Plug 'jistr/vim-nerdtree-tabs' " file browsing sidebar thing
  " TODO: figure out why &columns gives 80 on startup
  let g:nerdtree_tabs_open_on_console_startup=1             

Plug 'kien/ctrlp.vim'                  " fuzzy file opener
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
Plug 'bling/vim-airline'               " nifty vim statusline
"  let g:airline#extensions#tabline#enabled = 1

" completion - https://gregjs.com/vim/2016/configuring-the-deoplete-asynchronous-keyword-completion-plugin-with-tern-for-vim/
Plug 'Shougo/deoplete.nvim'            " completion bepis for NeoVim
  let g:deoplete#enable_at_startup = 1
  if !exists('g:deoplete#omni#input_patterns')
    let g:deoplete#omni#input_patterns = {}
  endif
  " auto-close the scratch window sometimes shown for completions at screen bottom
  autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif
Plug 'ervandew/supertab'               " complete using <TAB>
Plug 'racer-rust/vim-racer'            " needs `cargo install racer` and RUST_SRC_PATH
  let g:racer_cmd="racer"

" visual style
Plug 'jnurmine/Zenburn'                " the best color scheme ever made

" controls
Plug 'christoomey/vim-tmux-navigator'  " ctrl + HJKL to navigate vim & tmux splits
Plug 'Raimondi/delimitMate'            " paren matching. Shift-tab to jump out of delim,
                                       "   ctrl-c+thing to avoid
Plug 'tpope/vim-endwise'               " auto do..end in Ruby, etc

" commands
Plug 'tpope/vim-fugitive'              " :Gstatus, :Gedit, :Gdiff, :Glog, etc

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

call plug#end()
" }}} end plugins

set encoding=utf-8
scriptencoding utf-8

" appearance
set t_Co=256
syntax on
colors zenburn
set fillchars+=vert:\                  " (space after backslash) remove vertical pipe chars
set number
set ruler
set showmatch
set colorcolumn=100
highlight ColorColumn ctermbg=238


" Tabs. May be overriten by autocmd rules
set tabstop=2
set softtabstop=0
set shiftwidth=2
set expandtab
set smarttab

" backups: don't fuck up my local directories
set backupdir=~/.vim/_backup
set dir=~/.vim/_temp,/var/tmp,/tmp

" needed for some stuff

" neovim: terminal colors
" let g:terminal_color_0  = '#2e3436'
" let g:terminal_color_1  = '#cc0000'
" let g:terminal_color_2  = '#4e9a06'
" let g:terminal_color_3  = '#c4a000'
" let g:terminal_color_4  = '#3465a4'
" let g:terminal_color_5  = '#75507b'
" let g:terminal_color_6  = '#0b939b'
" let g:terminal_color_7  = '#d3d7cf'
" let g:terminal_color_8  = '#555753'
" let g:terminal_color_9  = '#ef2929'
" let g:terminal_color_10 = '#8ae234'
" let g:terminal_color_11 = '#fce94f'
" let g:terminal_color_12 = '#729fcf'
" let g:terminal_color_13 = '#ad7fa8'
" let g:terminal_color_14 = '#00f5e9'
" let g:terminal_color_15 = '#eeeeec'

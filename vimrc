" =============================================================================

                               set nocompatible

" =============================================================================
"                                    Vundle
" =============================================================================

filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'gmarik/Vundle.vim'               " this whole deal

" Commands
Plugin 'godlygeek/tabular'               " :Tabular align tabs
Plugin 'tpope/vim-fugitive'              " :Gstatus, :Gedit, :Gdiff, :Glog, etc
Plugin 'DamienCassou/textlint'           " :TextLint or <leader>tl. see :help quickfix

" Motions
Plugin 'scrooloose/nerdcommenter'        " leader c{c,u} to comment/uncomment
Plugin 'tpope/vim-surround'              " press cs({ to change parens to brackets
Plugin 'Lokaltog/vim-easymotion'         " press leader-leader then motion
Plugin 'mattn/emmet-vim'                 " zencoding motions: <c-y>,

" Widgets
Plugin 'kien/ctrlp.vim'                  " fuzzy file opener
Plugin 'scrooloose/nerdtree'             " files pane
Plugin 'jistr/vim-nerdtree-tabs'         " NerdTree in all tabs
Plugin 'bling/vim-airline'               " nifty vim statusline
Plugin 'edkolev/tmuxline.vim'            " vim statusline also in tmux

" Editor features
Plugin 'scrooloose/syntastic'            " syntax/error checker
Plugin 'christoomey/vim-tmux-navigator'  " CTRL+{h,j,k,l} betwen vim and tmux splits
Plugin 'chrisbra/Recover.vim'            " show diff when recovering file
Plugin 'tpope/vim-endwise'               " adds block-end keywords when opening blocks
Plugin 'Valloric/YouCompleteMe'          " advanced completions, requires cmake and gc++
Plugin 'flazz/vim-colorschemes'          " nice colors

" filetypes
Plugin 'vim-scripts/TWiki-Syntax'        " twiki, for vimperator mostly
Plugin 'tpope/vim-git'                   " ft git, gitcommit, gitconfig, gitrebase, gitsendemail
Plugin 'tpope/vim-haml'                  " ft .haml
Plugin 'tpope/vim-markdown'              " ft .md, .markdown
Plugin 'justinmk/vim-syntax-extra'       " ft .h, .c, bison, flex
Plugin 'jakar/vim-json'                  " ft .json
Plugin 'kchmck/vim-coffee-script'        " ft .coffee
Plugin 'groenewege/vim-less'             " ft .less

" Needs to be executed after Vundle.
call vundle#end()
filetype plugin indent on
"
" =============================================================================
"                               Plugin Settings
" =============================================================================

let g:nerdtree_tabs_open_on_console_startup=1

let g:airline#extensions#tabline#enabled = 1
let g:airline_theme='badwolf'
let g:airline_powerline_fonts=1

" let g:EasyMotion_leader_key = '<Leader>'
"
" Completion
" let g:SuperTabDefaultCompletionType = "context"
" let g:SuperTabClosePreviewOnPopupClose = 1
" " If you prefer the Omni-Completion tip window to close when a selection is
" " " made, these lines close it on movement in insert mode or when leaving
" " " insert mode
" autocmd CursorMovedI * if pumvisible() == 0|pclose|endif
" autocmd InsertLeave * if pumvisible() == 0|pclose|endif


" =============================================================================
"                               General settings
" =============================================================================

set autoindent          " Copy indent from current line on starting a new line.
"set smartindent         " And be smart about it
set smarttab
set backspace=indent,eol,start " Backspacing over everything in insert mode.
set hidden              " Allow for putting dirty buffers in background.
set history=1024        " Lines of command history
set ignorecase          " Case-insensitive search
set smartcase           " Override ignorecase when searching uppercase.
set incsearch           " Jumps to search word as you type.
set modeline            " Enables modelines.
set wildmode=longest,list:full " How to complete <Tab> matches.
"set tildeop            " Makes ~ an operator.
set virtualedit=block   " Support moving in empty space in block mode.
set mouse=a             " Enables mouse usage (all modes)
set magic               " Improves default search
set autoread            " Prompt to reread a file if it changes
set wrap                " Wraps long lines
set scrolloff=5         " Always shows five lines of vertical context around the cursor

" Low priority for these files in tab-completion.
set suffixes+=.aux,.bbl,.blg,.dvi,.log,.pdf,.fdb_latexmk
set suffixes+=.info,.out,.o,.lo,.bak,~,.swp,.o,.info,.log

set viminfo='20,\"500

scriptencoding utf-8


" =============================================================================
"                                  Formatting
" =============================================================================
set formatoptions=tcrqn " See :h 'fo-table for a detailed explanation.
set nojoinspaces        " Don't insert two spaces when joining after [.?!].
set copyindent          " Copy the structure of existing indentation
set expandtab           " Expand tabs to spaces.
set tabstop=4           " number of spaces for a <Tab>.
set shiftwidth=4        " Tab indention
"set textwidth=79        " Text width

" Indentation Tweaks.
" e-s = do not indent if opening bracket is not first character in a line.
" g0  = do not indent C++ scope declarations.
" t0  = do not indent a function's return type declaration.
" (0  = line up with next non-white character after unclosed parentheses...
" W4  = ...but not if the last character in the line is an open parenthesis.
set cinoptions=e-s,g0,t0,(0,W4

" =============================================================================
"                               Custom Functions
" =============================================================================

" =============================================================================
"                                 Key Bindings
" =============================================================================

let mapleader=","

:command NT NERDTreeTabsToggle
map <F2> :NERDTreeToggle<CR>

map! jj <Esc>
map gr gT
map j gj
map k gk

map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l

" Clear last search highlighting
nnoremap <CR> :noh<CR><CR>

" Toggle list mode (display unprintable characters).
nnoremap <F11> :set list!<CR>

" Close everything quickly
nnoremap QQ :qa<CR>

" Toggle paste mode.
set pastetoggle=<F12>
"
" =============================================================================
"                                Filetype Stuff
" =============================================================================

if &t_Co > 2 || has('gui_running')
  syntax on
endif

if has("spell")
  autocmd BufRead,BufNewFile *.dox  set spell
  autocmd Filetype mail             set spell
  autocmd Filetype tex              set spell
endif

au BufNewFile,BufRead *.hn setf yacc

" Makefiles don't like spaces
au FileType make set noexpandtab

" 2-space indents for some languages
au FileType coffee set sw=2 ts=2
au FileType ruby set sw=2 ts=2
au FileType java set sw=2 ts=2

" fucking textwrap in go? get out
au FileType go set textwidth=0 wrapmargin=0

" Fold Conf Files
au FileType conf syn region confBraces start="{" end="}" transparent fold


" =============================================================================
"                                   Styling
" =============================================================================
set background=dark     " Syntax highlighting for a dark terminal background.
set hlsearch            " Highlight search results.
set ruler               " Show the cursor position all the time.
set showbreak=↪         " Highlight non-wrapped lines.
set showcmd             " Display incomplete command in bottom right corner.
set showmatch           " Show matching brackets
set number              " Display line numbers

set t_Co=256            " We use 256 color terminal emulators these days.

" Folding
if version >= 600
    set foldenable
    set foldmethod=marker
endif

"let g:zenburn_high_Contrast=1
colors zenburn

" GVim Settings

" use monaco font
set gfn=Monaco:h10
set noantialias
if has("gui_running")
    if has("gui_gtk2")
        set guifont=Monaco\ 7.5
    elseif has("gui_win32")
        set guifont=Consolas:h11:cANSI
        set antialias
    endif
endif

" disable extraneous window buisness
set guioptions-=m  "remove menu bar
set guioptions-=T  "remove toolbar
set guioptions-=r  "remove right-hand scroll bar
set guioptions-=L  "remove left-hand scroll bar


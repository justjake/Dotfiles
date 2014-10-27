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
Plugin 'tacahiroy/ctrlp-funky'           " find functions in ctrl-p
Plugin 'scrooloose/nerdtree'             " files pane
Plugin 'jistr/vim-nerdtree-tabs'         " NerdTree in all tabs
Plugin 'bling/vim-airline'               " nifty vim statusline
Plugin 'taglist.vim'                     " nerdtree but for tags, unconfigured
Plugin 'xterm-color-table.vim'               " :XTermColorTable
"Plugin 'edkolev/tmuxline.vim'            " vim statusline also in tmux, breaks things

" Editor features
Plugin 'scrooloose/syntastic'            " syntax/error checker
Plugin 'christoomey/vim-tmux-navigator'  " CTRL+{h,j,k,l} betwen vim and tmux splits
Plugin 'chrisbra/Recover.vim'            " show diff when recovering file
Plugin 'tpope/vim-endwise'               " adds block-end keywords when opening blocks
Plugin 'Valloric/YouCompleteMe'          " advanced completions, requires cmake and gc++
Plugin 'flazz/vim-colorschemes'          " nice colors

" filetypes
Plugin 'vim-scripts/TWiki-Syntax'        " twiki, for vimperator mostly
Plugin 'tpope/vim-git'                   " ft git, gitcommit, gitconfig, gitrebase, etc
Plugin 'pangloss/vim-javascript'         " ft .js
Plugin 'tpope/vim-haml'                  " ft .haml
Plugin 'tpope/vim-markdown'              " ft .md, .markdown
Plugin 'justinmk/vim-syntax-extra'       " ft .h, .c, bison, flex
Plugin 'jakar/vim-json'                  " ft .json
Plugin 'kchmck/vim-coffee-script'        " ft .coffee
Plugin 'groenewege/vim-less'             " ft .less
Plugin 'tfnico/vim-gradle'               " ft .gradle
Plugin 'cakebaker/scss-syntax.vim'       " ft .scss, .sass
Plugin 'ap/vim-css-color'                " nicer colors in css-likes
Plugin 'rodjek/vim-puppet'               " ft .pp
Plugin 'ekalinin/Dockerfile.vim'         " ft Dockerfile
Plugin 'mxw/vim-jsx'

" Needs to be executed after Vundle.
call vundle#end()
filetype plugin indent on
"
" =============================================================================
"                               Plugin Settings
" =============================================================================

" only open tree on big editor terms
if &columns > 110
    let g:nerdtree_tabs_open_on_console_startup=1
endif

" when creating/switching buffers
set switchbuf=usetab,newtab
noremap <C-S-h> :tabprevious<CR>
noremap <C-S-l> :tabnext<CR>


let g:airline#extensions#tabline#enabled = 1
let g:airline_theme='badwolf'
let g:airline_powerline_fonts=1

" enable ctrlp-funky
let g:ctrlp_extensions = ['funky']
let g:ctrlp_funky_syntax_highlight = 1 " and syntax hilight ;)
nnoremap <C-F> :CtrlPFunky<Cr>
nnoremap <C-G> :execute 'CtrlPFunky ' . expand('<cword>')<Cr>

" Tag list on right side
let Tlist_Use_Right_Window = 1
nnoremap <C-C> :TlistToggle<Cr>


" let g:EasyMotion_leader_key = '<Leader>'
"
" Completion
" let g:SuperTabDefaultCompletionType = "context"
" let g:SuperTabClosePreviewOnPopupClose = 1
" If you prefer the Omni-Completion tip window to close when a selection is
" " made, these lines close it on movement in insert mode or when leaving
" " insert mode
autocmd CursorMovedI * if pumvisible() == 0|pclose|endif
autocmd InsertLeave * if pumvisible() == 0|pclose|endif

" settings for nerdcommenter Ctrl-/ to comment
vmap <C-_> <plug>NERDCommenterToggle
nmap <C-_> <plug>NERDCommenterToggle
imap <C-_> <plug>NERDCommenterInsert


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
set scrolloff=5         " Always shows five lines of vertical context around 
                        " the cursor

" Low priority for these files in tab-completion.
set suffixes+=.aux,.bbl,.blg,.dvi,.log,.pdf,.fdb_latexmk
set suffixes+=.info,.out,.o,.lo,.bak,~,.swp,.o,.info,.log

set viminfo='20,\"500

set backupdir=~/.vim/_backup
set dir=~/.vim/_temp,/var/tmp,/tmp

scriptencoding utf-8


" =============================================================================
"                                  Formatting
" =============================================================================
set formatoptions=tcrqn " See :h 'fo-table for a detailed explanation.
set nojoinspaces        " Don't insert two spaces when joining after [.?!].
set copyindent          " Copy the structure of existing indentation
set expandtab           " Expand tabs to spaces.
set tabstop=2           " number of spaces for a <Tab>.
set shiftwidth=2        " Tab indention
"set textwidth=79        " Text width

" Indentation Tweaks.
" e-s = do not indent if opening bracket is not first character in a line.
" g0  = do not indent C++ scope declarations.
" t0  = do not indent a function's return type declaration.
" (0  = line up with next non-white character after unclosed parentheses...
" W4  = ...but not if the last character in the line is an open parenthesis.
" set cinoptions=e-s,g0,t0,(0,W4

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

" Disable Ex mode because there's no reason for it to exist
map Q <Nop>

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
  autocmd Filetype md               set spell
  autocmd Filetype markdown         set spell
endif

au BufNewFile,BufRead *.hn setf yacc

" Makefiles don't like spaces
au FileType make set noexpandtab

" fucking textwrap in go? get out
au FileType go set textwidth=0 wrapmargin=0

au FileType python set ts=4 sw=4

" Fold Conf Files
au FileType conf syn region confBraces start="{" end="}" transparent fold

" OCaml + Merlin
if executable('ocamlmerlin') && has('python')
    let s:ocamlmerlin = substitute(system('opam config var share'), '\n$', '', '''') . "/ocamlmerlin"
    execute "set rtp+=".s:ocamlmerlin."/vim"
    execute "set rtp+=".s:ocamlmerlin."/vimbufsync"

    " syntax checking online
    let g:syntastic_ocaml_checkers = ['merlin']
endif

if executable('opam')
    let g:ocp_indent_vimfile = system("opam config var share")
    let g:ocp_indent_vimfile = substitute(g:ocp_indent_vimfile, '[\r\n]*$', '', '')
    let g:ocp_indent_vimfile = g:ocp_indent_vimfile . "/vim/syntax/ocp-indent.vim"

    autocmd FileType ocaml exec ":source " . g:ocp_indent_vimfile
endif


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
" don't complain if we don't have the schemes -- it's obv
silent! colors zenburn

" Colorcolumn - show 100 chars (we Airbnb now)
set colorcolumn=100
highlight ColorColumn ctermbg=238

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


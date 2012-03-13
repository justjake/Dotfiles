call pathogen#infect()

"Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

" allow backspacing over everything in insert mode
set backspace=eol,indent,start

" Make a backup before overwriting a file.  The backup is removed 
" after the file was successfully written
set writebackup

set ruler		" Show the cursor position all the time 
set showmatch		" Match Parens
set matchtime=500	" Match for half a second
set pastetoggle=<F3>	" Toggle our paste mode to not indent
set foldmethod=syntax	" Fold on syntax by default
set visualbell	" Noises are irritating

" Make vim smart
syntax enable
filetype plugin on
filetype indent on

" For twiki syntax folding
let g:Twiki_FoldAtHeadings = 1

" Break a line
map <Leader>f 072lBi<cr><esc>

" Tabbing
set autoindent		" Always have autoindenting on
set tabstop=4
set shiftwidth=4
set expandtab
set smarttab
" set shiftround
" set textwidth=72

" Makefiles don't like spaces
au FileType make set noexpandtab

" Fold Conf Files
au FileType conf syn region confBraces start="{" end="}" transparent fold

" I rarely write old-style sh. It's almost always bash:
let is_bash="true"

" Fix backspaces
set t_kb=
set t_kD=[3~

" If I paste and indentation gets fsck'd:
inoremap <silent> <C-g> <ESC>u:set paste<CR>.:set nopaste<CR>gi

" Tab Navigation
map <C-t> <ESC>:tabnew

" Stuff that's stolen from the net, not from milki, goes here

" Enable using the mouse to click to locations in the file!
" This also means vim takes control of the scrollwheel intelligently.
set mouse=a

" Search as you type
set incsearch
set hlsearch

" check perl code with :make
autocmd FileType perl set makeprg=perl\ -c\ %\ $*
autocmd FileType perl set errorformat=%F:%L:%m
autocmd FileType perl set autowrite

" show line numbers - make use of the extra screen real-estate with
" textwidth set to 72.  Up to 4 digits are okay for line numbers
set number
set numberwidth=4

" Appearance Options
set t_Co=256
set nowrap

"let g:zenburn_high_Contrast=1
" colors zenburn
let g:solarized_termcolors=256
set background=dark
colorscheme solarized

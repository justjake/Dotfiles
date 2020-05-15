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
Plug 'dense-analysis/ale'
" Diable annoying linters / fixers
" Some of these are suppied by CoC plugins, instead
let g:ale_linters = {
\  'javascript': [],
\  'typescript': [],
\  'ruby': [],
\  'java': [],
\}
let g:ale_fixers = {
\  'javascript': [],
\  'typescript': [],
\  'css': [],
\}
let g:ale_lint_on_text_changed = 'never'
let g:ale_fix_on_save = 1

" visual widgets
Plug 'scrooloose/nerdtree' | Plug 'jistr/vim-nerdtree-tabs' " file browsing sidebar thing
Plug 'Xuyuanp/nerdtree-git-plugin'
  " TODO: figure out why &columns gives 80 on startup
  let g:nerdtree_tabs_open_on_console_startup=1
  let NERDTreeShowHidden=1

"Plug 'ctrlpvim/ctrlp.vim'                  " fuzzy file opener
"  " search files + buffers + MRU
"  let g:ctrlp_cmd = 'CtrlPMixed'
"  " use ag for CtrlP
"  if executable('ag')
"    " use ag to list files - nice because fast and .gitignore support
"    let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
"    " ag fast, don't need cache
"    let g:ctrlp_use_caching = 0
"  endif

Plug 'airblade/vim-gitgutter'          " show git line status in gutter
Plug 'vim-airline/vim-airline'               " nifty vim statusline
Plug 'vim-airline/vim-airline-themes'
  let g:airline#extensions#ale#enabled = 1
"  let g:airline#extensions#tabline#enabled = 1

" completion - https://gregjs.com/vim/2016/configuring-the-deoplete-asynchronous-keyword-completion-plugin-with-tern-for-vim/
"Plug 'autozimu/LanguageClient-neovim', {
"    \ 'branch': 'next',
"    \ 'do': 'bash install.sh',
"    \ }
"  set hidden " Required for operations modifying multiple buffers like rename
"  let g:LanguageClient_serverCommands = {
"    \ 'go': system('which go-langserver')
"    \ }
  " example extra config:
  "nnoremap <silent> K :call LanguageClient#textDocument_hover()<CR>
  "nnoremap <silent> gd :call LanguageClient#textDocument_definition()<CR>
  "nnoremap <silent> <F2> :call LanguageClient#textDocument_rename()<CR>

Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
  " PlugInstall and PlugUpdate will clone fzf in ~/.fzf and run install script

" ProjectFiles tries to locate files relative to the git root contained in
" NerdTree, falling back to the current NerdTree dir if not available
" see https://github.com/junegunn/fzf.vim/issues/47#issuecomment-160237795
function! s:find_project_root()
  let nerd_root = g:NERDTree.ForCurrentTab().getRoot().path.str()
  let git_root = system('git -C '.shellescape(nerd_root).' rev-parse --show-toplevel 2> /dev/null')[:-2]
  if strlen(git_root)
    return git_root
  endif
  return nerd_root
endfunction
function! s:find_project_root_node_modules()
  let root = s:find_project_root()
  return root . "/node_modules"
endfunction
command! ProjectFiles execute 'Files' s:find_project_root()
command! ProjectNodeModules execute 'Files' s:find_project_root_node_modules()




" start CoC IDE ###############################################################
" https://github.com/neoclide/coc.nvim
" https://github.com/neoclide/coc.nvim/wiki/Using-coc-extensions
" https://www.npmjs.com/search?q=keywords%3Acoc.nvim
Plug 'neoclide/coc.nvim', {'branch': 'release'}
let g:coc_global_extensions = []
call add(g:coc_global_extensions, 'coc-tsserver')
call add(g:coc_global_extensions, 'coc-tslint-plugin')
call add(g:coc_global_extensions, 'coc-html')
call add(g:coc_global_extensions, 'coc-css')
call add(g:coc_global_extensions, 'coc-json')
call add(g:coc_global_extensions, 'coc-highlight')
call add(g:coc_global_extensions, 'coc-prettier')

" if hidden is not set, TextEdit might fail.
set hidden

" Unsure if this is needed w/ backupdir backups, but is reccomended by
" CoC's README.
" See https://github.com/neoclide/coc.nvim/issues/649
	" set nobackup
	" set nowritebackup

" Better display for messages
set cmdheight=2
" Smaller updatetime for CursorHold & CursorHoldI
set updatetime=300
" don't give |ins-completion-menu| messages.
set shortmess+=c
" always show signcolumns
set signcolumn=yes

" Use tab for trigger completion with characters ahead and navigate.
" Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
inoremap <silent><expr> <TAB> pumvisible() ? "\<C-n>" :  <SID>check_back_space() ? "\<TAB>" :  coc#refresh()

inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> for trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()

" Use <cr> for confirm completion, `<C-g>u` means break undo chain at current position.
" Coc only does snippet and additional edit on confirm.
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

" Use `[c` and `]c` for navigate diagnostics
nmap <silent> [c <Plug>(coc-diagnostic-prev)
nmap <silent> ]c <Plug>(coc-diagnostic-next)

" Remap keys for gotos
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K for show documentation in preview window
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if &filetype == 'vim'
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Highlight symbol under cursor on CursorHold
autocmd CursorHold * silent call CocActionAsync('highlight')


" Remap for rename current word
nmap <leader>rn <Plug>(coc-rename)

" Remap for format selected region
vmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Remap for do codeAction of selected region, ex: `<leader>aap` for current paragraph
vmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap for do codeAction of current line
nmap <leader>ac  <Plug>(coc-codeaction)
" Fix autofix problem of current line
nmap <leader>qf  <Plug>(coc-fix-current)

" Use `:Format` for format current buffer
command! -nargs=0 Format :call CocAction('format')

" Use `:Fold` for fold current buffer
command! -nargs=? Fold :call     CocAction('fold', <f-args>)


" Add diagnostic info for https://github.com/itchyny/lightline.vim
let g:lightline = {
      \ 'colorscheme': 'wombat',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'cocstatus', 'readonly', 'filename', 'modified' ] ]
      \ },
      \ 'component_function': {
      \   'cocstatus': 'coc#status'
      \ },
      \ }


" Using CocList
" Show all diagnostics
nnoremap <silent> <leader>a  :<C-u>CocList diagnostics<cr>
" Manage extensions
nnoremap <silent> <leader>e  :<C-u>CocList extensions<cr>
" Show commands
nnoremap <silent> <leader>c  :<C-u>CocList commands<cr>
" Find symbol of current document
nnoremap <silent> <leader>o  :<C-u>CocList outline<cr>
" Search workspace symbols
nnoremap <silent> <leader>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent> <leader>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent> <leader>k  :<C-u>CocPrev<CR>
" Resume latest coc list
nnoremap <silent> <leader>,  :<C-u>CocListResume<CR>

" end CoC IDE #################################################################




" Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' } " completion bepis for NeoVim
"   let g:deoplete#enable_at_startup = 1
"   if !exists('g:deoplete#omni#input_patterns')
"     let g:deoplete#omni#input_patterns = {}
"   endif
"   " auto-close the scratch window sometimes shown for completions at screen bottom
"   autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif
" Plug 'ervandew/supertab'               " complete using <TAB>
"   let g:SuperTabDefaultCompletionType = "<c-n>"
" Plug 'racer-rust/vim-racer'            " needs `cargo install racer` and RUST_SRC_PATH
"   let g:racer_cmd="racer"
"
" visual style
Plug 'jnurmine/Zenburn'                " the best color scheme ever made
Plug 'luochen1990/rainbow'           " rainbow parens
  let g:rainbow_active = 1
  let g:rainbow_conf = {
  \   'ctermfgs': ['4', '3', '12', '8', '10', '5'],
  \}
Plug 'google/vim-colorscheme-primary'
Plug 'NLKNguyen/papercolor-theme'
Plug 'chriskempson/base16-vim'         " a very cool colorcheme setup for script-based color config
                                       " check out the homepage: https://github.com/chriskempson/base16-shell


" controls
Plug 'christoomey/vim-tmux-navigator'  " ctrl + HJKL to navigate vim & tmux splits
Plug 'Raimondi/delimitMate'            " paren matching. Shift-tab to jump out of delim,
                                       "   ctrl-c+thing to avoid

" Disabled for conflict with CoC related bindings:
" Plug 'tpope/vim-endwise'               " auto do..end in Ruby, etc


" commands
Plug 'tpope/vim-fugitive'              " :Gstatus, :Gedit, :Gdiff, :Glog, etc
"Plug 'tpope/vim-sleuth'                " Automatically detect indentation
"  let g:sleuth_automatic = 0               " :Sleuth to run again

" automatic typo correction
Plug 'tpope/vim-abolish' | Plug 'jdelkins/vim-correction'
  let g:abolish_save_file = expand("~/.config/nvim/after/plugin/abolish.vim")
" :Subvert/address{,es}/reference{,s}/g
" :Abolish {despa,sepe}rat{e,es,ed,ing,ely,ion,ions,or}  {despe,sepa}rat{}
" crs (coerce to snake_case). MixedCase (crm), camelCase (crc), snake_case (crs), and UPPER_CASE (cru)

" I never bought this.
" Plug 'rizzatti/dash.vim'               " :Dash
"   nmap <silent> <leader>d <Plug>DashSearch

" motions
Plug 'scrooloose/nerdcommenter'        " leader c{c,u} to comment/uncomment
  " control-/ to toggle commenting on a line
  vmap <C-_> <plug>NERDCommenterToggle
  nmap <C-_> <plug>NERDCommenterToggle
  imap <C-_> <plug>NERDCommenterInsert
Plug 'Lokaltog/vim-easymotion'         " press leader-leader then motion

" snippets. this is new, and maybe should be disabled until the user is ready.
" Plug 'Shougo/neosnippet.vim'           " snippets engine
" Plug 'Shougo/neosnippet-snippets'      " snippets lib

" TypeScript
Plug 'HerringtonDarkholme/yats.vim' " syntax needed for deoplete-typescript
  let g:yats_host_keyword = 0       " don't highlight addEventLister & similar

"Plug 'leafgarland/typescript-vim'
"Plug 'peitalin/vim-jsx-typescript'
" Plug 'HerringtonDarkholme/deoplete-typescript'
" Plug 'mhartington/nvim-typescript', {'do': './install.sh'}

" golang
"Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
  " press K to get docs
  let g:go_auto_type_info = 1          " Type info under cursor
  " ts expands to type | struct
  " ti expands to type | interface
  " ife expands to if err != nil { | }
  let g:go_snippet_engine = "neosnippet"
  " go-to-declaration
  au FileType go nmap <leader>gt :GoDeclsDir<cr>
  " auto-import stuff
  let g:go_fmt_command = "goimports"
" Plug 'mdempsky/gocode', { 'rtp': 'nvim', 'do': '~/.config/nvim/plug/gocode/nvim/symlink.sh' }
"Plug 'zchee/deoplete-go', { 'do': 'make' }
  "let g:deoplete#sources#go#gocode_binary = $GOPATH.'/bin/gocode'
" good doc: https://hackernoon.com/my-neovim-setup-for-go-7f7b6e805876

" Plug 'sebastianmarkow/deoplete-rust'
"   let g:deoplete#sources#rust#racer_binary=$HOME.'/.cargo/bin/racer'
"   let g:deoplete#sources#rust#rust_source_path=$HOME.'/src/rust'

" filetypes not otherwise supported
Plug 'sheerun/vim-polyglot'            " many languages
  let g:polyglot_disabled = ['go']     " we use upstream go
  let g:jsx_ext_required = 0           " in js files, too

call plug#end()

" vim-abolish settings
" }}} end plugins

set encoding=utf-8
scriptencoding utf-8

" appearance
set t_Co=256
syntax on
"set background=dark
"set background=light
"colorscheme PaperColor
" Load the current base16-vim color scheme.
if filereadable(expand("~/.vimrc_background"))
  let base16colorspace = 256

  " We have silent! here because this will only succeed once the base16-vim
  " plugin is installed.
  silent! source ~/.vimrc_background
  let g:airline_theme = 'base16'
  let g:airline_powerline_fonts = 1

  " Customize some hard-to-read error colors
  hi SpellBad           ctermfg=7 ctermbg=9
  hi NvimInternalError  ctermfg=7 ctermbg=9
else
  colors zenburn               " aaaaaand activate
endif

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
nnoremap <leader>f :ProjectFiles<CR>
nnoremap <leader>fn :ProjectNodeModules<CR>
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
"
" Wrap lines at word boundaries and make the wrapping more obvious.
set showbreak=..
set breakindent
set breakindentopt=shift:2,sbr

" Turn on spell checking everywhere.
" set spell spelllang=en_us
"syntax spell toplevel
"autocmd Syntax * :syntax spell toplevel

" filetype customization {{{
autocmd Filetype gitcommit setlocal spell textwidth=72
" }}}

" strip trailing whitespace
fun! StripTrailingWhitespace()
    " Only strip if the b:noStripWhitespace variable isn't set
    if exists('b:noStripWhitespace')
        return
    endif
    if getline(1) =~ "noStripWhitespace"
        return
    endif

    exe "normal mz"
    %s/\s\+$//ge
    exe "normal `z"
endfun

autocmd BufWritePre * call StripTrailingWhitespace()
autocmd FileType markdown let b:noStripWhitespace=1

au BufRead,BufEnter /Users/jitl/src/notion/*.{js,ts,tsx,json} set ts=2 sw=2 noet

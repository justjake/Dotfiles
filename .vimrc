set nocompatible
set bs=2
set mouse=a

" Colorscheme
syntax enable
"set background=dark
"colorscheme solarized

" Zenburn colorscheme - the one true colorscheme
colors zenburn

" Indentation
set shiftwidth=2
set tabstop=2

if has("autocmd")
  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on
endif

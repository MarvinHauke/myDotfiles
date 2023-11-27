colorscheme slate

if has("termguicolors") == 1
    set termguicolors
    hi ColorColumn ctermbg=NONE guibg=#42413c 
else
    hi ColorColumn ctermbg=235 guibg=NONE
endif
"Set leaderkey
let mapleader=" "

"Disable compatiblity with vi
set nocompatible

"Enable type File detection
filetype on
filetype plugin on
filetype indent on
syntax on

"Set encoding
set encoding=utf-8

set ts=4
set sts=4
set sw=4
set autoindent
set autoread
set smartindent
set smarttab
set expandtab
set backspace=indent,eol,start

"Set search mechanism
set ignorecase
set smartcase
set showmatch
set hlsearch "highlight searchresults
set incsearch "automaticly jump to the next search result

"Set mode moddifications
set showmode "shows the actual mode you are in
set showcmd "show partial coommand you type in the last line of the screen

"Set auto completion
set wildmenu "shows completion menu after pressing tab
set wildmode=list:longest "behave similar to bashcompletion
set wildignore=*.docx,*.jpg,*.png "ignore wildmenu in this files

" Cursor appearence settings:
" Reference chart of Values:
" PS = 0 -> blinking block.
" PS = 1 -> blinking block. (default)
" PS = 2 -> steady block.
" PS = 3 -> blinking underline.
" PS = 4 -> steady underline.
" PS = 5 -> blinking bar.
" PS = 6 -> steady bar.
let &t_SI = "\e[5 q"
let &t_EI = "\e[1 q"
set ttimeoutlen=-1 "<- this setting sets the timeout between esc sequences for example switching between normal and insert (default is -1)

"Set number appearence:
set nu
set rnu
set colorcolumn=80

"Set Stausbar bottom
"type ":help statusline" for more information
set laststatus=2
set statusline=%<%f\ %h%m%r%=%b\[%l,%v]\ %{&filetype}

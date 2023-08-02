colorscheme slate
syntax on
set showmatch
set ts=4
set sts=4
set sw=4
set autoindent
set autoread
set backspace=indent,eol,start
set smartindent
set smarttab
set expandtab
set nu
set rnu

" Cursor appearence settings:
" Reference chart of Values:
" PS = 0 -> blinking block.
" PS = 1 -> blinking block. (default)
" PS = 2 -> steady block.
" PS = 3 -> blinking underline.
" PS = 4 -> steady underline.
" PS = 5 -> blinking bar.
" PS = 6 -> steady bar.
let &t_SI = "\e[6 q"
let &t_EI = "\e[1 q"
set ttimeoutlen=5 "<- this setting sets the timeout between esc sequences for example switching between normal and insert

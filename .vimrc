"Disable compatiblity with vi
set nocompatible

"Colorsettings
colorscheme slate

if has("termguicolors") == 1
    set termguicolors
endif

"Normalmode Remaps
nnoremap <leader>vc :vsp $MYVIMRC<cr>
nnoremap <leader>bc :vsp ~/.bashrc<cr>
nnoremap <leader>w :wincmd w<cr>
nnoremap <leader>nh :noh<cr> 

"Visualmode Remaps
"vnoremap K :m '<-2<CR>gv=gv
vnoremap J :<C-U>call MoveVisualLines('down')<CR>
vnoremap K :<C-U>call MoveVisualLines('up')<CR>

" Function to move visual lines up or down
function! MoveVisualLines(direction)
  let l:start_line = line("'<")
  let l:end_line = line("'>")

  if a:direction == 'down'
    let l:destination_line = l:end_line + 1
  elseif a:direction == 'up' && l:start_line > 1
    let l:destination_line = l:start_line - 1
  else
    return
  endif

  let line_range = start_line . ',' . end_line
  let destination = a:direction == 'down' ? destination_line : destination_line - 1
  execute line_range . 'm ' . destination
  normal! gv
endfunction

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
"set incsearch "automaticly jump to the next search result

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
set ttimeoutlen=5 "<- this setting sets the timeout between esc sequences for
"example switching between normal and insert

"Column appearence:
set nu
set rnu
set colorcolumn=80

"Stausbar bottom
"type ":help statusline" for more information
set laststatus=2

"Statusline settings
set statusline=%<%f\ %h%m%r%=%b\[%l,%v]\ %{&filetype}

"Check Systemtype
if has('win32') || has('win64')
   call Windows() 
endif

"Set leaderkey
let mapleader = "\<Space>"


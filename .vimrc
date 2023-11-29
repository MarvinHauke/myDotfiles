"Disable compatiblity with vi
set nocompatible

"Define all Funktions
function! Windows()
    set runtimepath+=~/.vim "sets the default folder to ~/.vim under windows
    if empty(glob('~/.vim/autoload/plug.vim'))
        iwr -useb https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim |`
        ni $HOME/.vim/autoload/plug.vim -Force
        finish
    endif
endfunction

"Colorsettings
colorscheme slate

if has("termguicolors") == 1
    set termguicolors
endif


"Set leaderkey
let mapleader = "\<Space>"

"Normalmode Remaps
nnoremap <leader>vc :vsp $MYVIMRC<cr>
nnoremap <leader>bc :vsp ~/.bashrc<cr>
nnoremap <leader>w :wincmd w<cr>
nnoremap <leader>nh :noh<cr> 
nnoremap <leader>e :NERDTreeToggle<cr>

"Insertmode Remaps
inoremap <C-S-E> <ESC>:NERDTreeToggle<cr>


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

call plug#begin(has('nvim') ? stdpath('data') . '/plugged' : '~/.vim/plugged')

" NERD tree will be loaded on the first invocation of NERDTreeToggle command
Plug 'preservim/nerdtree', { 'on': 'NERDTreeToggle' }

Plug 'mg979/vim-visual-multi', {'branch': 'master'}

call plug#end()
" You can revert the settings after the call like so:
"   filetype indent off   " Disable file-type-specific indentation
"   syntax off            " Disable syntax highlighting

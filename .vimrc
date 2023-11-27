"Colorsettings
colorscheme slate

if has("termguicolors") == 1
    set termguicolors
endif

"Set leaderkey
let mapleader="\<Space>"

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
set ttimeoutlen=5 "<- this setting sets the timeout between esc sequences for
"example switching between normal and insert

"Column appearence:
set nu
set rnu
set colorcolumn=80

"Stausbar bottom
"type ":help statusline" for more information
set laststatus=2


set statusline=%<%f\ %h%m%r%=%b\[%l,%v]\ %{&filetype}



"Plugins
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'

if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '
    \.data_dir.'/autoload/plug.vim --create-dirs 
    \https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Install vim-plug if not found
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs 
    \https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
endif

" Run PlugInstall if there are missing plugins
autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \| PlugInstall --sync | source $MYVIMRC
\| endif

call plug#begin()
" The default plugin directory will be as follows:
"   - Vim (Linux/macOS): '~/.vim/plugged'
"   - Vim (Windows): '~/vimfiles/plugged'
"   - Neovim (Linux/macOS/Windows): stdpath('data') . '/plugged'
" You can specify a custom plugin directory by passing it as the argument
"   - e.g. `call plug#begin('~/.vim/plugged')`
"   - Avoid using standard Vim directory names like 'plugin'

" Make sure you use single quotes

" Shorthand notation; fetches https://github.com/junegunn/vim-easy-align
" Plug 'junegunn/vim-easy-align'

" Any valid git URL is allowed
"Plug 'https://github.com/junegunn/vim-github-dashboard.git'

" Multiple Plug commands can be written in a single line using | separators
"Plug 'SirVer/ultisnips' | Plug 'honza/vim-snippets'

" On-demand loading
"Plug 'preservim/nerdtree', { 'on': 'NERDTreeToggle' }
"Plug 'tpope/vim-fireplace', { 'for': 'clojure' }

" Using a non-default branch
"Plug 'rdnetto/YCM-Generator', { 'branch': 'stable' }

" Using a tagged release; wildcard allowed (requires git 1.9.2 or above)
"Plug 'fatih/vim-go', { 'tag': '*' }

" Plugin options
"Plug 'nsf/gocode', { 'tag': 'v.20150303', 'rtp': 'vim' }

" Plugin outside ~/.vim/plugged with post-update hook
"Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }

" Unmanaged plugin (manually installed and updated)
"$Plug '~/my-prototype-plugin'

" Initialize plugin system
" - Automatically executes `filetype plugin indent on` and `syntax enable`.
call plug#end()
" You can revert the settings after the call like so:
"   filetype indent off   " Disable file-type-specific indentation
"   syntax off            " Disable syntax highlighting

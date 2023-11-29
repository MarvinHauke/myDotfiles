"Make nvim use ~/.vimrc as configfile
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath=&runtimepath
source $HOME/.vimrc

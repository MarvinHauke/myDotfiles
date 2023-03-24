" @version      
" @since        
" @last-update  
" @author       
" @licence      

" @info         This is my .vimrc file form (neo)vim.You can also find this
"               .vimrc at https://github.com/MarvinHauke/myDotfiles feel free to use
"               whatever you find and like from this file.

" =============================================================================
set nocompatible                " Don't by like vi be VIM
let mapleader = ","             " Set mapleader
filetype off                    " 

" {{{ --- Encoding -------------------------------------------------------------
set encoding=utf-8                   " output in the terminal
set fileencoding=utf-8               " output in file
" }}}

" {{{ --- Folding --------------------------------------------------------------
set foldenable						 " enable folding
set foldmethod=marker                " Set default fold method
set foldlevelstart=1                 " all tabs are closed on file load
set foldnestmax=5                    " 5 nested fold max
" }}}

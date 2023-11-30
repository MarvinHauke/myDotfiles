"Make nvim use ~/.config/nvim/init.vim 
let luaconfig = expand('~/.config/nvim/init.lua')

if filereadable(luaconfig)
    echo "using init.lua"
    execute 'source ' . luaconfig
else
    echo "using init.vim"
    source ~/.config/nvim/init.vim
endif

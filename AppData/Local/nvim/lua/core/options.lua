vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.opt.backspace = '2'
vim.opt.showcmd = true
vim.opt.laststatus = 2
vim.opt.autowrite = true
vim.opt.cursorline = true
vim.opt.autoread = true

-- use spaces for tabs and whatnot
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.shiftround = true
vim.opt.expandtab = true

vim.cmd [[ set noswapfile ]]
vim.cmd [[ set termguicolors ]]

--this goes to "~/.vim/undodir"
vim.opt.undodir = vim.fn.stdpath('config') .. '\\undodir'
vim.opt.undofile = true

--Line numbers
vim.wo.number = true
vim.opt.relativenumber = true
vim.opt.colorcolumn = "80"
vim.opt.scrolloff = 8
vim.opt.wrap = false

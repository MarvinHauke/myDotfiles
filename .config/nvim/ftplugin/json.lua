-- Folding
vim.opt_local.foldmethod = "expr"
vim.opt_local.foldexpr = "v:lua.vim.lsp.foldexpr()"
vim.opt_local.foldlevel = 99
vim.opt_local.foldnestmax = 8

-- Indentation
vim.opt_local.tabstop = 2
vim.opt_local.softtabstop = 2
vim.opt_local.shiftwidth = 2
vim.opt_local.expandtab = true

-- Display
vim.opt_local.number = true
vim.opt_local.relativenumber = true

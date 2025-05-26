-- Use spaces, not tabs
vim.opt_local.expandtab = true

-- Set indent width to 8 (as per your stylua config)
vim.opt_local.shiftwidth = 4
vim.opt_local.tabstop = 4
vim.opt_local.softtabstop = 4

-- Optional: smarter indentation
vim.opt_local.smartindent = true
vim.opt_local.autoindent = true
vim.notify("Loaded lua filetype settings")

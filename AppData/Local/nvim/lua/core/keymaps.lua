-- Navigate vim panes better
vim.keymap.set('n', '<c-k>', ':wincmd k<CR>')
vim.keymap.set('n', '<c-j>', ':wincmd j<CR>')
vim.keymap.set('n', '<c-h>', ':wincmd h<CR>')
vim.keymap.set('n', '<c-l>', ':wincmd l<CR>')


-- Lets your Cursor stay in Place while "J"
vim.keymap.set("n", "J", "mzJ`z")

-- Delete to void Register
vim.keymap.set("n", "<leader>d", "\"_dd")
vim.keymap.set("v", "<leader>d", "\"_d")

-- Move lines in Visual Mode
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Copy to clipboard
vim.keymap.set("n", "<leader>y", "\"*yy")
vim.keymap.set("v", "<leader>y", "\"*y")

-- Paste from clipboard
vim.keymap.set("n", "<leader>p", "\"*p")
vim.keymap.set("v", "<leader>p", "\"*p")

vim.keymap.set('n', '<leader>h', ':nohlsearch<CR>')

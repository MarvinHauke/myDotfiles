-- This File contains all keymaps, which are not related to specific buffers.
-- They can be used from every where at any time in vim.

-- Set leader key to space (done in init.lua)
-- vim.g.mapleader = " "

local opts = { noremap = true, silent = true }
local term_opts = { slient = true }
local keymap = vim.keymap
local utils = require("helper.utils")

-- Modes:
--   normal_mode = "n",
--   insert_mode = "i",
--   visual_mode = "v",
--   visual_block_mode = "x",
--   term_mode = "t",
--   command_mode = "c",

-- General keymaps
keymap.set("n", "<leader>wq", ":wq<CR>", { desc = "save and quit" })
keymap.set("n", "<leader>qq", ":BufDelAll<CR>", { desc = "quit all open buffers" })
keymap.set("n", "<leader>ww", ":w<CR>", { desc = "save" })

-- Split window management
keymap.set("n", "<leader>sp", "<C-w>v", { desc = "split window vertically" })
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "split window horizontally" })
keymap.set("n", "<leader>se", "<C-w>=", { desc = "make split windows equal width" })
keymap.set("n", "<leader><Esc>", ":close<CR>", { desc = "close current split window" })

-- Close command-line windows with Esc
vim.api.nvim_create_autocmd("CmdwinEnter", {
	callback = function()
		vim.keymap.set("n", "<Esc>", ":close<CR>", { buffer = true, desc = "Close command-line window" })
	end,
})

-- Close search-history (q/) window as well
vim.api.nvim_create_autocmd("FileType", {
	pattern = "qf",
	callback = function()
		vim.keymap.set("n", "<Esc>", ":close<CR>", { buffer = true, desc = "Close search-history window" })
	end,
})

-- Close quickfix-window and help-window
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "qf", "help" },
	callback = function()
		vim.keymap.set("n", "<Esc>", ":close<CR>", { buffer = true, desc = "Close search-history window" })
	end,
})

-- Tab management
keymap.set("n", "<leader>tn", ":tabn<CR>", { desc = "next tab" }) -- next tab
keymap.set("n", "<leader>tp", ":tabp<CR>", { desc = "previous tab" }) -- previous tab

-- Utils from core.utils
keymap.set("n", "ge", utils.open_command_with_filepath, { desc = "open current path in cmd" })

-- Diff keymaps
keymap.set("n", "<leader>cc", ":diffput<CR>") -- put diff from current to other during diff
keymap.set("n", "<leader>cj", ":diffget 1<CR>") -- get diff from left (local) during merge
keymap.set("n", "<leader>ck", ":diffget 3<CR>") -- get diff from right (remote) during merge
keymap.set("n", "<leader>cn", "]c", { desc = "next diff" })
keymap.set("n", "<leader>cp", "[c", { desc = "prev diff" })

-- Move lines in Visual Mode
keymap.set("v", "J", ":m '>+1<CR>gv=gv")
keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Improve Indents
keymap.set("v", "<", "<gv", opts)
keymap.set("v", ">", ">gv", opts)

-- Copy to clipboard
keymap.set("n", "<leader>y", '"*yy', { desc = "copy to clipboard" })
keymap.set("v", "<leader>y", '"*y', { desc = "copy to clipboard" })

-- Paste from clipboard
keymap.set("n", "<leader>p", '"*p', { desc = "paste from clipboard" })
keymap.set("v", "<leader>p", '"*p', { desc = "paste from clipboard" })

-- Clear seach highlighting
keymap.set("n", "<leader>hl", ":nohlsearch<CR>", { desc = "clear search highlight" })

-- Lets your Cursor stay in Place while "J"
-- keymap.set("n", "J", "mzJ`z")
keymap.set("n", "J", "<NOP>", opts) -- remove J from normal mode

-- Quickfix keymaps
keymap.set("n", "<leader>qn", ":cnext<CR>", { desc = "quickfix list next" })
keymap.set("n", "<leader>qp", ":cprev<CR>", { desc = "quickfix list prev" })

-- Vim-maximizer
keymap.set("n", "<leader>sm", ":MaximizerToggle<CR>") -- toggle maximize tab

-- Git-blame
keymap.set("n", "<leader>gb", ":GitBlameToggle<CR>", { desc = "GitBlameToggle" })

-- Bufferline
keymap.set("n", "J", ":BufferLineCyclePrev<CR>")
keymap.set("n", "K", ":BufferLineCycleNext<CR>")

-- Vim REST Console
keymap.set("n", "<leader>xr", ":call VrcQuery()<CR>", { desc = "run REST query" })

-- Nvim-dap
keymap.set("n", "<leader>bb", "<cmd>lua require'dap'.toggle_breakpoint()<cr>", { desc = "set Breakpoint" })
keymap.set(
	"n",
	"<leader>bc",
	"<cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<cr>",
	{ desc = "set Breakpoint description" }
)
keymap.set(
	"n",
	"<leader>bl",
	"<cmd>lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<cr>",
	{ desc = "set Breakpoint Log message" }
)
keymap.set("n", "<leader>br", "<cmd>lua require'dap'.clear_breakpoints()<cr>", { desc = "clear breakpoint" })
keymap.set("n", "<leader>ba", "<cmd>Telescope dap list_breakpoints<cr>", { desc = "list breakpoints" })
keymap.set("n", "<leader>dc", "<cmd>lua require'dap'.continue()<cr>", { desc = "dap continue" })
keymap.set("n", "<leader>dj", "<cmd>lua require'dap'.step_over()<cr>", { desc = "dap setop over" })
keymap.set("n", "<leader>dk", "<cmd>lua require'dap'.step_into()<cr>", { desc = "dap step into" })
keymap.set("n", "<leader>do", "<cmd>lua require'dap'.step_out()<cr>", { desc = "dap step out" })

keymap.set("n", "<leader>dd", function()
	require("dap").disconnect()
	require("dapui").close()
end)

keymap.set("n", "<leader>dt", function()
	require("dap").terminate()
	require("dapui").close()
end)

keymap.set("n", "<leader>dr", "<cmd>lua require'dap'.repl.toggle()<cr>")
keymap.set("n", "<leader>dl", "<cmd>lua require'dap'.run_last()<cr>")

keymap.set("n", "<leader>di", function()
	require("dap.ui.widgets").hover()
end)
keymap.set("n", "<leader>d?", function()
	local widgets = require("dap.ui.widgets")
	widgets.centered_float(widgets.scopes)
end)

-- Telescope dap
keymap.set("n", "<leader>df", "<cmd>Telescope dap frames<cr>")
keymap.set("n", "<leader>dh", "<cmd>Telescope dap commands<cr>")
keymap.set("n", "<leader>de", function()
	require("telescope.builtin").diagnostics({ default_text = ":E:" })
end)

-- Nvim-Tree
keymap.set("n", "-", "<cmd>NvimTreeToggle<CR>", { desc = "toggle nvim tree" })

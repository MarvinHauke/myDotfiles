-- Set leader key to space
-- vim.g.mapleader = " "

local opts = { noremap = true, silent = true }
local term_opts = { slient = true }
local keymap = vim.keymap

-- Modes:
--   normal_mode = "n",
--   insert_mode = "i",
--   visual_mode = "v",
--   visual_block_mode = "x",
--   term_mode = "t",
--   command_mode = "c",

-- General keymaps
keymap.set("n", "<leader>bd", ":BufDel<CR>", opts, { desc = "close buffer" })       -- close buffer
keymap.set("n", "<leader>wq", ":wq<CR>", { desc = "save and quit" })                -- save and quit
keymap.set("n", "<leader>qq", ":BufDelAll<CR>", { desc = "quit all open buffers" }) -- quit all open buffers
keymap.set("n", "<leader>ww", ":w<CR>", { desc = "save" })                          -- save

-- Split window management
keymap.set("n", "<leader>sp", "<C-w>v", { desc = "split window vertically" })        -- split window vertically
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "split window horizontally" })      -- split window horizontally
keymap.set("n", "<leader>se", "<C-w>=", { desc = "make split windows equal width" }) -- make split windows equal width
keymap.set("n", "<leader>sx", ":close<CR>", { desc = "close current split window" }) -- close split window

-- Better window navigation
keymap.set("n", "<c-k>", ":wincmd k<CR>") -- lower window
keymap.set("n", "<c-j>", ":wincmd j<CR>") -- upper window
keymap.set("n", "<c-h>", ":wincmd h<CR>") -- left window
keymap.set("n", "<c-l>", ":wincmd l<CR>") -- right window

-- Tab management
keymap.set("n", "<leader>to", ":tabnew<CR>", { desc = "open new tab" }) -- open a new tab
keymap.set("n", "<leader>tx", ":tabclose<CR>", { desc = "close tab" })  -- close a tab
keymap.set("n", "<leader>tn", ":tabn<CR>", { desc = "next tab" })       -- next tab
keymap.set("n", "<leader>tp", ":tabp<CR>", { desc = "previous tab" })   -- previous tab

-- Resize with arrows
keymap.set("n", "<C-Up>", ":resize +2<CR>")
keymap.set("n", "<C-Down>", ":resize -2<CR>")
keymap.set("n", "<C-Left>", ":vertical resize +2<CR>")
keymap.set("n", "<C-Right>", ":vertical resize -2<CR>")

-- Oil
keymap.set("n", "-", "<CMD>Oil --float<CR>", { desc = "Open parent directory" })

-- Diff keymaps
keymap.set("n", "<leader>cc", ":diffput<CR>")   -- put diff from current to other during diff
keymap.set("n", "<leader>cj", ":diffget 1<CR>") -- get diff from left (local) during merge
keymap.set("n", "<leader>ck", ":diffget 3<CR>") -- get diff from right (remote) during merge
keymap.set("n", "<leader>cn", "]c")             -- next diff hunk
keymap.set("n", "<leader>cp", "[c")             -- previous diff hunk

-- Move lines in Visual Mode
keymap.set("v", "J", ":m '>+1<CR>gv=gv")
keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Improve Indents
keymap.set("v", "<", "<gv", opts)
keymap.set("v", ">", ">gv", opts)

-- Copy to clipboard
keymap.set("n", "<leader>y", '"*yy')
keymap.set("v", "<leader>y", '"*y')

-- Paste from clipboard
keymap.set("n", "<leader>p", '"*p')
keymap.set("v", "<leader>p", '"*p')

-- Clear search highlighting
keymap.set("n", "<leader>h", ":nohlsearch<CR>")

keymap.set("n", "J", "<NOP>", opts) -- remove J from normal mode

-- Quickfix keymaps
keymap.set("n", "<leader>qn", ":cnext<CR>") -- jump to next quickfix list item
keymap.set("n", "<leader>qp", ":cprev<CR>") -- jump to prev quickfix list item

-- Vim-maximizer
keymap.set("n", "<leader>sm", ":MaximizerToggle<CR>") -- toggle maximize tab

-- Bufferline
keymap.set("n", "J", ":BufferLineCyclePrev<CR>")
keymap.set("n", "K", ":BufferLineCycleNext<CR>")

-- LSP
keymap.set("n", "<leader>gg", "<cmd>lua vim.lsp.buf.hover()<CR>")
keymap.set("n", "<leader>gd", "<cmd>lua vim.lsp.buf.definition()<CR>", { desc = "go to definition" })
keymap.set("n", "<leader>gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", { desc = "go to declaration" })
keymap.set("n", "<leader>gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", { desc = "go to implementation" })
keymap.set("n", "<leader>gt", "<cmd>lua vim.lsp.buf.type_definition()<CR>")
keymap.set("n", "<leader>gr", "<cmd>lua vim.lsp.buf.references()<CR>")
keymap.set("n", "<leader>gs", "<cmd>lua vim.lsp.buf.signature_help()<CR>")
keymap.set("n", "<leader>rr", "<cmd>lua vim.lsp.buf.rename()<CR>")
keymap.set("n", "<leader>gf", "<cmd>lua vim.lsp.buf.format({async = true})<CR>", { desc = "format file with lsp" })
keymap.set("v", "<leader>gf", "<cmd>lua vim.lsp.buf.format({async = true})<CR>", { desc = "format file with lsp" })
keymap.set("n", "<leader>ga", "<cmd>lua vim.lsp.buf.code_action()<CR>", { desc = "toggle code action" })
keymap.set("n", "<leader>gl", "<cmd>lua vim.diagnostic.open_float()<CR>")
keymap.set("n", "<leader>gp", "<cmd>lua vim.diagnostic.goto_prev()<CR>")
keymap.set("n", "<leader>gn", "<cmd>lua vim.diagnostic.goto_next()<CR>")
keymap.set("n", "<leader>tr", "<cmd>lua vim.lsp.buf.document_symbol()<CR>")
keymap.set("n", "<leader>k", "<cmd>lua vim.lsp.buf.hover()<CR>")
keymap.set("i", "<C-Space>", "<cmd>lua vim.lsp.buf.completion()<CR>")

-- Conform
keymap.set({ "n", "v" }, "<leader>mp", function()
  require("conform").format({
    lsp_fallback = true,
    async = false,
    timeout_ms = 1000,
  })
end, { desc = "Format file or range (in visual mode)" })

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
keymap.set("n", "<leader>wq", ":wq<CR>", { desc = "save and quit" })       -- save and quit
keymap.set("n", "<leader>qq", ":q!<CR>", { desc = "quit without saving" }) -- quit without saving
keymap.set("n", "<leader>ww", ":w<CR>", { desc = "save" })                 -- save

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

-- Open URL under Cursor
-- keymap.set("n", "gx", ":URLOpenUnderCursor<CR>", { desc = "open URL under cursor" }) --deprecated is now a nvim default

-- Diff keymaps
keymap.set("n", "<leader>cc", ":diffput<CR>")   -- put diff from current to other during diff
keymap.set("n", "<leader>cj", ":diffget 1<CR>") -- get diff from left (local) during merge
keymap.set("n", "<leader>ck", ":diffget 3<CR>") -- get diff from right (remote) during merge
keymap.set("n", "<leader>cn", "]c")             -- next diff hunk
keymap.set("n", "<leader>cp", "[c")             -- previous diff hunk

-- Delete to void Register
-- keymap.set("n", "<leader>d", '"_dd')
-- keymap.set("v", "<leader>d", '"_d')

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

-- Clear seach highlighting
keymap.set("n", "<leader>h", ":nohlsearch<CR>") -- clear search highlight

-- Lets your Cursor stay in Place while "J"
-- keymap.set("n", "J", "mzJ`z")
keymap.set("n", "J", "<NOP>", opts) -- remove J from normal mode


-- Quickfix keymaps
keymap.set("n", "<leader>qn", ":cnext<CR>") -- jump to next quickfix list item
keymap.set("n", "<leader>qp", ":cprev<CR>") -- jump to prev quickfix list item

-- Vim-maximizer
keymap.set("n", "<leader>sm", ":MaximizerToggle<CR>") -- toggle maximize tab

-- Nvim-tree
keymap.set("n", "<leader>ee", ":NvimTreeToggle<CR>")   -- toggle file explorer
keymap.set("n", "<leader>er", ":NvimTreeFocus<CR>")    -- toggle focus to file explorer
keymap.set("n", "<leader>ef", ":NvimTreeFindFile<CR>") -- find file in file explorer

-- Git-blame
keymap.set("n", "<leader>gb", ":GitBlameToggle<CR>") -- toggle git blame

-- Bufferline
keymap.set("n", "J", ":BufferLineCyclePrev<CR>")
keymap.set("n", "K", ":BufferLineCycleNext<CR>")

-- Harpoon
keymap.set("n", "<leader>ha", require("harpoon.mark").add_file)
keymap.set("n", "<leader>hh", require("harpoon.ui").toggle_quick_menu)
keymap.set("n", "<leader>h1", function()
  require("harpoon.ui").nav_file(1)
end)
keymap.set("n", "<leader>h2", function()
  require("harpoon.ui").nav_file(2)
end)
keymap.set("n", "<leader>h3", function()
  require("harpoon.ui").nav_file(3)
end)
keymap.set("n", "<leader>h4", function()
  require("harpoon.ui").nav_file(4)
end)
keymap.set("n", "<leader>h5", function()
  require("harpoon.ui").nav_file(5)
end)
keymap.set("n", "<leader>h6", function()
  require("harpoon.ui").nav_file(6)
end)
keymap.set("n", "<leader>h7", function()
  require("harpoon.ui").nav_file(7)
end)
keymap.set("n", "<leader>h8", function()
  require("harpoon.ui").nav_file(8)
end)
keymap.set("n", "<leader>h9", function()
  require("harpoon.ui").nav_file(9)
end)

-- Vim REST Console
keymap.set("n", "<leader>xr", ":call VrcQuery()<CR>") -- Run REST query

-- LSP
keymap.set("n", "<leader>gg", "<cmd>lua vim.lsp.buf.hover()<CR>")
keymap.set("n", "<leader>gd", "<cmd>lua vim.lsp.buf.definition()<CR>", { desc = "go to definition" })
keymap.set("n", "<leader>gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", { desc = "go to declaration" })
keymap.set("n", "<leader>gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", { desc = "go to declaration" })
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

-- Nvim-dap
keymap.set("n", "<leader>bb", "<cmd>lua require'dap'.toggle_breakpoint()<cr>")
keymap.set("n", "<leader>bc", "<cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<cr>")
keymap.set("n", "<leader>bl", "<cmd>lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<cr>")
keymap.set("n", "<leader>br", "<cmd>lua require'dap'.clear_breakpoints()<cr>")
keymap.set("n", "<leader>ba", "<cmd>Telescope dap list_breakpoints<cr>")
keymap.set("n", "<leader>dc", "<cmd>lua require'dap'.continue()<cr>")
keymap.set("n", "<leader>dj", "<cmd>lua require'dap'.step_over()<cr>")
keymap.set("n", "<leader>dk", "<cmd>lua require'dap'.step_into()<cr>")
keymap.set("n", "<leader>do", "<cmd>lua require'dap'.step_out()<cr>")
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
keymap.set("n", "<leader>df", "<cmd>Telescope dap frames<cr>")
keymap.set("n", "<leader>dh", "<cmd>Telescope dap commands<cr>")
keymap.set("n", "<leader>de", function()
  require("telescope.builtin").diagnostics({ default_text = ":E:" })
end)

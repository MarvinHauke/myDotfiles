return {
	{
		"kyazdani42/nvim-tree.lua",
		enabled = true,
		dependencies = {
			{
				"b0o/nvim-tree-preview.lua",
				dependencies = {
					"nvim-lua/plenary.nvim",
					"3rd/image.nvim", -- Optional, for previewing images
				},
			},
		},

		-- init runs at startup, so these commands exist before nvim-tree is loaded
		init = function()
			local utils = require("helper.utils")
			local function cmd(name, fn, desc)
				vim.api.nvim_create_user_command(name, function(a)
					local path = a.args ~= "" and vim.fn.fnamemodify(a.args, ":p") or vim.fn.expand("%:p")
					if path == "" then
						vim.notify(name .. ": no file", vim.log.levels.WARN)
						return
					end
					fn(path)
				end, { nargs = "?", complete = "file", desc = desc })
			end
			cmd("Zathura", utils.open_zathura, "Open file (default: current) in detached zathura")
			cmd("OpenHex", utils.open_hex, "Open file (default: current) as hex dump (xxd)")
			cmd("OpenRaw", utils.open_raw, "Open file (default: current) as raw text (latin1)")
		end,

		config = function()
			local api = require("nvim-tree.api")
			local utils = require("helper.utils")

			-- Open PDFs in a detached zathura window (does not block nvim), everything else as usual.
			local function open_node(node)
				node = node or api.tree.get_node_under_cursor()
				if node and node.type == "file" and node.name:lower():match("%.pdf$") then
					utils.open_zathura(node.absolute_path)
				else
					api.node.open.edit()
				end
			end

			-- Open the file under the cursor with the given utils.open_* function
			local function open_node_with(open_fn)
				return function()
					local node = api.tree.get_node_under_cursor()
					if not node or node.type ~= "file" then
						return
					end
					api.node.open.edit() -- focuses the target window
					open_fn(node.absolute_path)
				end
			end

			-- Define a custom on_attach function for nvim-tree buffers.
			local function on_attach(bufnr)
				local function opts(desc)
					return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
				end

				-- Apply nvim-tree's default mappings
				api.config.mappings.default_on_attach(bufnr)

				-- Free <C-k> (default: info popup) so vim-tmux-navigator can move between panes; info moves to "gi"
				pcall(vim.keymap.del, "n", "<C-k>", { buffer = bufnr })
				vim.keymap.set("n", "gi", api.node.show_info_popup, opts("Info"))

				-- Custom key mappings for nvim-tree:
				vim.keymap.set("n", "<CR>", open_node, opts("Open (PDF via zathura)"))
				vim.keymap.set("n", "o", open_node, opts("Open (PDF via zathura)"))
				vim.keymap.set("n", "<2-LeftMouse>", open_node, opts("Open (PDF via zathura)"))
				vim.keymap.set("n", "gb", open_node_with(utils.open_hex), opts("Open as hex (xxd)"))
				vim.keymap.set("n", "gt", open_node_with(utils.open_raw), opts("Open as raw text (latin1)"))
				vim.keymap.set("n", "_", api.tree.change_root_to_parent, opts("Change root to parent"))
				vim.keymap.set("n", "?", api.tree.toggle_help, opts("Toggle help"))
				vim.keymap.set("n", "<ESC>", api.tree.close, opts("Close"))
				vim.keymap.set("n", "-", api.tree.close, opts("Close"))

				-- Custom key mappings for nvim-tree-preview:
				local preview = require("nvim-tree-preview")
				vim.keymap.set("n", "P", preview.watch, opts("Open Preview"))
				vim.keymap.set("n", "<CTRL-k>", function()
					return preview.scroll(4)
				end, opts("Scroll Down"))
				vim.keymap.set("n", "<CTRL-j>", function()
					return preview.scroll(-4)
				end, opts("Scroll Up"))
			end

			-- Setup nvim-tree with your settings and the custom on_attach function.
			require("nvim-tree").setup({
				disable_netrw = true,
				hijack_netrw = true,
				git = {
					ignore = false, -- show files and folders which are listed in .gitignore files
				},
				view = {
					width = 30,
					side = "left",
				},
				renderer = {
					icons = {
						glyphs = {
							default = "",
							symlink = "",
							git = {
								unstaged = "✗",
								staged = "✓",
								unmerged = "",
								renamed = "➜",
								untracked = "★",
								deleted = "",
								ignored = "◌",
							},
						},
					},
				},
				on_attach = on_attach, -- Pass our keymapping function
			})

			-- Optionally, if nvim-tree-preview provides extra configuration, you can configure it here as well:
			require("nvim-tree-preview").setup({
				-- Add your preview settings if needed
			})
		end,
	},
}

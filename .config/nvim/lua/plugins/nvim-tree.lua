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

		config = function()
			local api = require("nvim-tree.api")

			-- Define a custom on_attach function for nvim-tree buffers.
			local function on_attach(bufnr)
				local function opts(desc)
					return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
				end

				-- Apply nvim-tree's default mappings
				api.config.mappings.default_on_attach(bufnr)

				-- Custom key mappings for nvim-tree:
				vim.keymap.set("n", "_", api.tree.change_root_to_parent, opts("Change root to parent"))
				vim.keymap.set("n", "?", api.tree.toggle_help, opts("Toggle help"))
				vim.keymap.set("n", "<ESC>", api.tree.close, opts("Close"))
				vim.keymap.set("n", "-", api.tree.close, opts("Close"))

				-- Custom key mappings for nvim-tree-preview:
				local preview = require("nvim-tree-preview")
				vim.keymap.set("n", "p", preview.watch, opts("Open Preview"))
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

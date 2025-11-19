-- Fuzzy finder
return {
	-- https://github.com/nvim-telescope/telescope.nvim
	"nvim-telescope/telescope.nvim",
	lazy = true,
	branch = "0.1.x",
	dependencies = {
		-- https://github.com/nvim-lua/plenary.nvim
		{ "nvim-lua/plenary.nvim" },

		-- https://github.com/nvim-telescope/telescope-fzf-native.nvim
		{
			"nvim-telescope/telescope-fzf-native.nvim",
			build = "make",
			cond = function()
				return vim.fn.executable("make") == 1
			end,
		},
	},
	-- Convert opts to a function so we can load and use telescope.actions
	opts = function()
		-- Load the actions module for use in mappings
		local actions = require("telescope.actions")
		return {
			defaults = {
				layout_config = {
					vertical = {
						width = 0.75,
					},
				},
				-- Custom key mappings for the Telescope window
				mappings = {
					i = {
						-- In Insert mode: Ctrl-J moves to the next result
						["<C-j>"] = actions.move_selection_next,
						-- In Insert mode: Ctrl-K moves to the previous result
						["<C-k>"] = actions.move_selection_previous,
					},
					n = {
						-- In Normal mode: Ctrl-J moves to the next result
						["<C-j>"] = actions.move_selection_next,
						-- In Normal mode: Ctrl-K moves to the previous result
						["<C-k>"] = actions.move_selection_previous,
					},
				},
			},
		}
	end,

	vim.api.nvim_create_user_command("Nvc", function()
		require("telescope.builtin").find_files({
			prompt_title = "< Neovim Config >",
			cwd = vim.fn.expand("$HOME") .. "/.config/nvim",
			search_dirs = { vim.fn.expand("$HOME") .. "/.config/nvim" },
		})
	end, {}),

	-- keymaps for telescope
	keys = {
		{ "<leader>ff", ":Telescope find_files<cr>", desc = "find files" },
		{ "<leader>fg", ":Telescope live_grep<cr>", desc = "live grep" },
		{ "<leader>fb", ":Telescope buffers<cr>", desc = "buffers" },
		{ "<leader>fh", ":Telescope help_tags<cr>", desc = "help tags" },
		{ "<leader>fk", ":Telescope keymaps<cr>", desc = "search through all keymaps" },
		{ "<leader>fs", ":Telescope current_buffer_fuzzy_find<cr>", desc = "current buffer fuzzy find" },
		{ "<leader>fo", ":Telescope lsp_document_symbols<cr>", desc = "lsp document symbols" },
		{ "<leader>fi", ":Telescope lsp_incoming_calls<cr>", desc = "lsp incoming calls" },
		{ "<leader>nv", ":Nvc<cr>", desc = "search in neovim config" },
		-- find methods in current buffer with treesitter
		{
			"<leader>fm",
			function()
				require("telescope.builtin").treesitter({ default_text = ":method:" })
			end,
			desc = "treesitter method search",
		},
		-- 	vim.keymap.set("n", "<leader>fm", function()
		-- 		require("telescope.builtin").treesitter({ default_text = ":method:" })
		-- 	end),
	},
}

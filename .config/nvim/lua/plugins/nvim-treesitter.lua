-- Code Tree Support / Syntax Highlighting
return {
	-- https://github.com/nvim-treesitter/nvim-treesitter
	"nvim-treesitter/nvim-treesitter",
	event = "VeryLazy",
	dependencies = {
		-- https://github.com/nvim-treesitter/nvim-treesitter-textobjects
		"nvim-treesitter/nvim-treesitter-textobjects",
		-- https://github.com/nvim-treesitter/playground
		"nvim-treesitter/playground",
	},
	build = ":TSUpdate",
	opts = {
		highlight = {
			enable = true,
		},
		indent = { enable = true },
		auto_install = true, -- automatically install syntax support when entering new file type buffer
		ensure_installed = {
			"arduino",
			"c",
			"lua",
			"bash",
			"cmake",
			"cpp",
			"python",
			"javascript",
			"vim",
			"vimdoc",
			"html",
			"norg",
		},
	},
	config = function(_, opts)
		local configs = require("nvim-treesitter.configs")
		configs.setup(opts)
	end,
}

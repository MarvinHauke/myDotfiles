return {
	"nvimdev/lspsaga.nvim",
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"nivm-tree/nvim-web-devicons",
	},
	config = function()
		require("lspsaga").setup({})
	end,
}

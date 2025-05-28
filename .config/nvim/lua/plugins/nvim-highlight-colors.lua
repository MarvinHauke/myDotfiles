return {
	-- additionaly add the setup() in core/options.lua under
	-- opt.termguicolors = true
	-- require("nvim-highlight-colors").setup({})
	"brenoprata10/nvim-highlight-colors",
	event = "VeryLazy",
	config = function()
		require("nvim-highlight-colors").setup({})
	end,
}

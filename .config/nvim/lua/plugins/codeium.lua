return {
	"Exafunction/codeium.nvim",
	dpendencies = {
		"nvim-lua/plenary.nvim",
		"hrsh7th/nvim-cmp",
	},
	enabled = true,
	config = function()
		local codeium = require("codeium")
		codeium.setup()
	end,
}

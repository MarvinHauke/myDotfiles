return {
	"anurag3301/nvim-platformio.lua",
	enabled = true,
	dependencies = {
		{ "akinsho/nvim-toggleterm.lua" },
		{ "nvim-telescope/telescope.nvim" },
		{ "nvim-lua/plenary.nvim" },
		{ "coddingtonbear/neomake-platformio" },
	},
	cmd = {
		"Pioinit",
		"Piorun",
		"Piocmd",
		"Piolib",
		"Piomon",
		"Piodebug",
		"Piodb",
	},
}

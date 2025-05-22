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
	lsp = "clangd",

	keys = {
		vim.keymap.set("n", "<leader>pb", ":Piorun build<CR>", { desc = "PlatformIO Build" }),
		vim.keymap.set("n", "<leader>pu", ":Piorun upload<CR>", { desc = "PlatformIO Upload" }),
		vim.keymap.set("n", "<leader>pm", ":Piomon<CR>", { desc = "PlatformIO Monitor" }),
	},
}

return {
	dir = "~/Development/lua/tickets.nvim", -- path to your local development copy
	-- "MarvinHauke/tickets.nvim", -- pull via lazy
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		require("tickets").setup({
			target_file = "TODO.md", -- or any other path
		})

		--Keymappings
		vim.keymap.set("n", "<leader>tdl", ":Tickets<CR>", { noremap = true, silent = true, desc = "Open todos file" })
		vim.keymap.set(
			"n",
			"<leader>tdf",
			":TicketsGithubFetch<CR>",
			{ noremap = true, desc = "Fetch Issues from Github" }
		)
	end,
	dev = true,
}

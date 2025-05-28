return {
	dir = "~/Development/lua/tickets.nvim", -- path to your local development copy
	-- "MarvinHauke/tickets.nvim", -- pull via lazy
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		require("tickets").setup({
			target_file = "~/Notizen/Todos/tasks.md", -- or any other path
		})

		--Keymappings
		vim.keymap.set("n", "<leader>tdl", ":Td<CR>", { noremap = true, silent = true, desc = "Open todos file" })
		vim.keymap.set("n", "<leader>tdg", ":GithubFetch<CR>", { noremap = true, desc = "Fetch Issues from Github" })
	end,
}

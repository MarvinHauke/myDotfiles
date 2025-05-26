return {
	"MarvinHauke/tickets.nvim", -- replace with your GitHub username
	config = function()
		require("tickets").setup({
			target_file = "~/Notizen/Todos/tasks.md", -- or any other path
		})

		--Keymappings
		vim.keymap.set("n", "<leader>td", ":Td<CR>", { noremap = true, silent = true, desc = "Open todos file" })
	end,
}

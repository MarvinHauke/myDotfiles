-- lua/plugins/ufo.lua
return {
	"kevinhwang91/nvim-ufo",
	dependencies = {
		"kevinhwang91/promise-async",
	},
	event = "VeryLazy",
	opts = {
		provider_selector = function(bufnr, filetype, buftype)
			return { "lsp", "indent" }
		end,
	},
	init = function()
		-- UFO benötigt diese Einstellungen
		vim.o.foldcolumn = "0" -- show folding column on the left
		vim.o.foldlevel = 99
		vim.o.foldlevelstart = 99
		vim.o.foldenable = true
	end,
	config = function(_, opts)
		require("ufo").setup(opts)

		-- Optional: Keymaps
		vim.keymap.set("n", "zR", require("ufo").openAllFolds, { desc = "Open all folds" })
		vim.keymap.set("n", "zM", require("ufo").closeAllFolds, { desc = "Close all folds" })
		vim.keymap.set("n", "zr", require("ufo").openFoldsExceptKinds, { desc = "Open folds except kinds" })
		vim.keymap.set("n", "zm", require("ufo").closeFoldsWith, { desc = "Close folds with" })
		vim.keymap.set("n", "zp", function()
			local winid = require("ufo").peekFoldedLinesUnderCursor()
			if not winid then
				vim.lsp.buf.hover()
			end
		end, { desc = "Peek fold or show hover" })
	end,
}

-- | Code Tree Support / Syntax Highlighting |
return {
	-- https://github.com/nvim-treesitter/nvim-treesitter
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	dependencies = {
		-- https://github.com/nvim-treesitter/nvim-treesitter-textobjects
		{ "nvim-treesitter/nvim-treesitter-textobjects", branch = "main" },
	},
	build = ":TSUpdate",
	config = function()
		local install = require("nvim-treesitter.install")

		-- ensure parsers are installed (skips already-installed ones)
		install.install({
			"arduino",
			"bash",
			"c",
			"cpp",
			"cmake",
			"lua",
			"make",
			"python",
			"javascript",
			"vim",
			"vimdoc",
			"html",
			"markdown",
			"markdown_inline",
			"json",
		})

		-- auto-install parser when entering a new filetype
		-- also check if the filetype is available
		local available = require("nvim-treesitter.config").get_available()
		vim.api.nvim_create_autocmd("FileType", {
			callback = function(args)
				local lang = vim.treesitter.language.get_lang(args.match)
				if lang and vim.list_contains(available, lang) then
					pcall(install.install, { lang })
					pcall(vim.treesitter.start, args.buf)
				end
			end,
		})

		-- treesitter-based folding
		vim.opt.foldmethod = "expr"
		vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
		vim.opt.foldenable = false -- open all folds by default
	end,
}

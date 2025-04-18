-- Theme/Colorscheme
return {
	-- https://github.com/rebelot/kanagawa.nvim
	"catppuccin/nvim", -- You can replace this with your favorite colorscheme
	lazy = false, -- We want the colorscheme to load immediately when starting Neovim
	priority = 1000, -- Load the colorscheme before other non-lazy-loaded plugins
	enable = true,
	opts = {
		flavour = "mocha",
		-- Replace this with your scheme-specific settings or remove to use the defaults
		background = {
			light = "ladde",
			dark = "mocha",
		},
		styles = {
			comments = { "italic" },
			loops = {},
			functions = {},
			keywords = {},
			strings = {},
			variables = {},
			numbers = {},
			booleans = {},
			properties = {},
			types = {},
			operators = {},
		},
	},
	config = function(_, opts)
		require("catppuccin").setup(opts) -- Replace this with your favorite colorscheme
		vim.cmd("colorscheme catppuccin") -- Replace this with your favorite colorscheme
		-- Colorscheme overrides
		vim.cmd([[
      autocmd VimEnter * hi DiffAdd guifg=#00FF00 guibg=#005500
      autocmd VimEnter * hi DiffDelete guifg=#FF0000 guibg=#550000
      autocmd VimEnter * hi DiffChange guifg=#CCCCCC guibg=#555555
      autocmd VimEnter * hi DiffText guifg=#00FF00 guibg=#005500
    ]])
	end,
}

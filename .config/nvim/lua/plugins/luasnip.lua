return {
	"L3MON4D3/LuaSnip",
	-- loaded by nvim-cmp (or a require). cmp_luasnip belongs to nvim-cmp: as a dependency here it
	-- loaded cmp in the middle of startup and the other cmp sources (cmdline, path, buffer) never registered.
	lazy = true,
	dependencies = {
		"rafamadriz/friendly-snippets",
	},
	version = "2.*",
	build = "make install_jsregexp",
	opts = {
		history = true,
		updateevents = "TextChanged,TextChangedI",
		enable_autosnippets = true,
	},
}

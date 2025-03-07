return {
	"L3MON4D3/LuaSnip",
	dependencies = {
		"saadparwaiz1/cmp_luasnip",
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

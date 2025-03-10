local ls = require("luasnip")

--ls.parser.parse_snippet(<text>, <VSCode style snippet>)
ls.nippets({
	all = {
		-- Available in any filetype
		ls.parser.parse_snippet("test", "-- test comment"),
	},

	lua = {
		-- Available in lua filetype
	},
})

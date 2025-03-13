-- Auto-completion / Snippets generated with the following video
-- https://www.youtube.com/watch?v=y1WWOaLCNyI
return {
	"hrsh7th/nvim-cmp", -- https://github.com/hrsh7th/nvim-cmp
	event = "InsertEnter",
	dependencies = {
		"hrsh7th/cmp-buffer", -- source for text in buffer
		"hrsh7th/cmp-path", -- source for file system paths
		"hrsh7th/cmp-cmdline", -- source for vim commandline https://github.com/hrsh7th/cmp-cmdline
		"hrsh7th/cmp-nvim-lua", -- source for neovim lua api https://github.com/hrsh7th/cmp-nvim-lua
		"L3MON4D3/LuaSnip",
		"saadparwaiz1/cmp_luasnip", -- for autocompletion
		"rafamadriz/friendly-snippets", --useful snippets
		"onsails/lspkind.nvim", -- vs-code like pictograms -- https://github.com/onsails/lspkind.nvim
		"hrsh7th/cmp-emoji", -- source for markdown emojis https://github.com/hrsh7th/cmp-emoji
	},
	config = function()
		local cmp = require("cmp")
		local luasnip = require("luasnip")
		local lspkind = require("lspkind")

		-- loads vscode style snippets from installed plugins (e.g. friendly-snippets)
		require("luasnip.loaders.from_vscode").lazy_load()

		-- TODO: cmd line completion for ":" and "/"
		cmp.setup({
			-- Experimental feature of nvim-cmp
			experimental = {
				ghost_text = true,
			},

			completion = {
				completeopt = "menu,menuone,preview,noselect",
			},
			-- configure lspkind for vs-code like pictograms
			formatting = {
				format = lspkind.cmp_format({
					mode = "symbol_text",
					menu = {
						buffer = "[Buffer]",
						codeium = "[AI]",
						nvim_lsp = "[LSP]",
						luasnip = "[LuaSnip]",
						path = "[Path]",
						neorg = "[Neorg]",
					},
				}),
			},

			snippet = {
				expand = function(args)
					luasnip.lsp_expand(args.body)
					-- vim.snippet.expand(args.body)
					-- cmp.resubscribe({ "TextChanged", "TextChangedI" })
					-- require("cmp.configure").set_onetime({ sources = {} })
				end,
			},
			-- Windows for autocompletion
			window = {
				completion = cmp.config.window.bordered(),
				documentation = cmp.config.window.bordered(),
			},
			-- keymappings for completions
			mapping = cmp.mapping.preset.insert({
				["<C-k>"] = cmp.mapping.select_prev_item(), -- previous suggestion
				["<S-Tab>"] = cmp.mapping.select_prev_item(), -- previous suggestion
				["<C-j>"] = cmp.mapping.select_next_item(), -- next suggestion
				["<Tab>"] = cmp.mapping.select_next_item(), -- next suggestion
				["<C-b>"] = cmp.mapping.scroll_docs(-4), -- scroll backward
				["<C-f>"] = cmp.mapping.scroll_docs(4), -- scroll forward
				["<C-Space>"] = cmp.mapping.complete(), -- show completion suggestions
				["<C-e>"] = cmp.mapping.abort(), -- clear completion window
				["<CR>"] = cmp.mapping.confirm({ select = false }), -- confirm selection
			}),
			-- sources for autocompletion
			-- They are hirached in the order they are listed
			sources = {
				{ name = "nvim_lsp" }, -- lsp
				{ name = "luasnip" }, -- snippets
				{ name = "buffer" }, -- text within current buffer
				{ name = "codeium" },
				{ name = "path" }, -- file system paths
				{ name = "neorg" }, -- neorg
				{ name = "emoji" },
			},
		})
	end,
}

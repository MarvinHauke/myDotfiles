-- Auto-completion / Snippets generated with the following video
-- https://www.youtube.com/watch?v=y1WWOaLCNyI
return {
	"hrsh7th/nvim-cmp", -- https://github.com/hrsh7th/nvim-cmp
	event = "InsertEnter",
	dependencies = {
		"hrsh7th/cmp-buffer", -- source for text in buffer
		"hrsh7th/cmp-path", -- source for file system paths
		"hrsh7th/cmp-cmdline", -- source for vim commandline  https://github.com/hrsh7th/cmp-cmdline
		"hrsh7th/cmp-nvim-lua", -- source for neovim lua api  https://github.com/hrsh7th/cmp-nvim-lua
		"hrsh7th/cmp-calc", -- source for math                https://github.com/hrsh7th/cmp-calc
		"L3MON4D3/LuaSnip",
		"saadparwaiz1/cmp_luasnip", -- for autocompletion
		"rafamadriz/friendly-snippets", --useful snippets
		"onsails/lspkind.nvim", -- vs-code like pictograms    https://github.com/onsails/lspkind.nvim
		"hrsh7th/cmp-emoji", -- source for markdown emojis    https://github.com/hrsh7th/cmp-emoji
		"tamago324/cmp-zsh", -- contains zsh completions      https://github.com/tamago324/cmp-zsh
	},
	config = function()
		local cmp = require("cmp")
		local luasnip = require("luasnip")
		local lsp_kinds = {
			Class = " ",
			Color = " ",
			Constant = " ",
			Constructor = " ",
			Enum = " ",
			EnumMember = " ",
			Event = " ",
			Field = " ",
			File = " ",
			Folder = " ",
			Function = " ",
			Interface = " ",
			Keyword = " ",
			Method = " ",
			Module = " ",
			Operator = " ",
			Property = " ",
			Reference = " ",
			Snippet = " ",
			Struct = " ",
			Text = " ",
			TypeParameter = " ",
			Unit = " ",
			Value = " ",
			Variable = " ",
			Codeium = "󱙺", -- my own icon added from nerdfonts TODO: color it
		}

		-- loads vscode style snippets from installed plugins (e.g. friendly-snippets)
		require("luasnip.loaders.from_vscode").lazy_load()

		-- cmdline completion for ":"
		-- This may contains Bugs!!!
		cmp.setup.cmdline(":", {
			mapping = cmp.mapping.preset.cmdline(),
			sources = cmp.config.sources({
				{ name = "path" },
			}, {
				{ name = "cmdline" },
			}),
			matching = { disallow_symbol_nonprefix_matching = false },
		})

		-- Normal Cmp setup
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
				format = function(entry, vim_item)
					-- Kind icons
					vim_item.kind = string.format("%s %s", lsp_kinds[vim_item.kind], vim_item.kind) -- This concatenates the icons with the name of the item kind
					-- Source
					vim_item.menu = ({
						buffer = "[Buffer]",
						nvim_lsp = "[LSP]",
						luasnip = "[LuaSnip]",
						nvim_lua = "[Lua]",
						latex_symbols = "[LaTeX]",
						codeium = "[AI]",
						zsh = "[SHELL]",
					})[entry.source.name]
					return vim_item
				end,
			},
			-- Snippet function
			snippet = {
				expand = function(args)
					luasnip.lsp_expand(args.body)
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
				["<Tab><Space>"] = cmp.mapping.complete(), -- show completion suggestions
				["<C-e>"] = cmp.mapping.abort(), -- clear completion window
				["<CR>"] = cmp.mapping.confirm({ select = false }), -- confirm selection
			}),
			-- sources for autocompletion
			-- They are hirached in the order they are listed
			sources = {
				{ name = "nvim_lsp" }, -- lsp
				{ name = "luasnip" }, -- snippets
				{ name = "buffer" }, -- text within current buffer
				{ name = "codeium" }, -- ai completion
				{ name = "path" }, -- file system paths
				{ name = "neorg" }, -- neorg
				{ name = "calc" }, -- math
				{ name = "zsh" }, -- shellcompletion
				{ name = "emoji" }, -- fun
			},
		})
	end,
}

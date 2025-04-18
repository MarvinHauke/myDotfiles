-- Auto-completion / Snippets generated with the following video
-- https://www.youtube.com/watch?v=y1WWOaLCNyI
-- It also heavily uses the following config https://github.com/wincent/wincent/blob/64947cd9efc70844ee6f1a1d44dd381a3ec6569a/aspects/nvim/files/.config/nvim/after/plugin/nvim-cmp.lua
-- And the following video
-- https://www.youtube.com/watch?v=gK31IVy0Gp0

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
		-- Convenience wrapper around nvim_replace_termcodes() for use when defining
		-- expression mappings; eg:
		--
		--    nnoremap('<C-a>', function () return rhs('<Tab>') end, {expr = true})
		--
		-- Converts a string representation of a mapping's RHS (eg. "<Tab>") into an
		-- internal representation (eg. "\t").
		local rhs = function(rhs_str)
			return vim.api.nvim_replace_termcodes(rhs_str, true, true, true)
		end
		local has_luasnip, luasnip = pcall(require, "luasnip")
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

		-- Returns the current column number.
		local column = function()
			local ok, pos = pcall(vim.api.nvim_win_get_cursor, 0)
			if ok and pos and #pos == 2 then
				return pos[2]
			else
				return 0
			end
		end

		-- Based on (private) function in LuaSnip/lua/luasnip/init.lua.
		local in_snippet = function()
			local session = require("luasnip.session")
			local node = session.current_nodes[vim.api.nvim_get_current_buf()]
			if not node then
				return false
			end
			local snippet = node.parent.snippet
			local snip_begin_pos, snip_end_pos = snippet.mark:pos_begin_end()
			local pos = vim.api.nvim_win_get_cursor(0)
			if pos[1] - 1 >= snip_begin_pos[1] and pos[1] - 1 <= snip_end_pos[1] then
				return true
			end
		end

		-- Returns true if the cursor is in leftmost column or at a whitespace
		-- character.
		local in_whitespace = function()
			local col = column()
			return col == 0 or vim.api.nvim_get_current_line():sub(col, col):match("%s")
		end

		local in_leading_indent = function()
			local col = column()
			local line = vim.api.nvim_get_current_line()
			local prefix = line:sub(1, col)
			return prefix:find("^%s*$")
		end

		local shift_width = function()
			if vim.o.softtabstop <= 0 then
				return vim.fn.shiftwidth()
			else
				return vim.o.softtabstop
			end
		end

		-- Complement to `smart_tab()`.
		-- When 'noexpandtab' is set (ie. hard tabs are in use), backspace:
		--
		--    - On the left (ie. in the indent) will delete a tab.
		--    - On the right (when in trailing whitespace) will delete enough
		--      spaces to get back to the previous tabstop.
		--    - Everywhere else it will just delete the previous character.
		--
		-- For other buffers ('expandtab'), we let Neovim behave as standard and that
		-- yields intuitive behavior, unless the `dedent` parameter is truthy, in
		-- which case we issue <C-D> to dedent (see `:help i_CTRL-D`).
		local smart_bs = function(dedent)
			local keys = nil
			if vim.o.expandtab then
				if dedent then
					keys = rhs("<C-D>")
				else
					keys = rhs("<BS>")
				end
			else
				local col = column()
				local line = vim.api.nvim_get_current_line()
				local prefix = line:sub(1, col)
				if in_leading_indent() then
					keys = rhs("<BS>")
				else
					local previous_char = prefix:sub(#prefix, #prefix)
					if previous_char ~= " " then
						keys = rhs("<BS>")
					else
						-- Delete enough spaces to take us back to the previous tabstop.
						--
						-- Originally I was calculating the number of <BS> to send, but
						-- Neovim has some special casing that causes one <BS> to delete
						-- multiple characters even when 'expandtab' is off (eg. if you hit
						-- <BS> after pressing <CR> on a line with trailing whitespace and
						-- Neovim inserts whitespace to match.
						--
						-- So, turn 'expandtab' on temporarily and let Neovim figure out
						-- what a single <BS> should do.
						--
						-- See `:h i_CTRL-\_CTRL-O`.
						keys = rhs("<C-\\><C-o>:set expandtab<CR><BS><C-\\><C-o>:set noexpandtab<CR>")
					end
				end
			end
			vim.api.nvim_feedkeys(keys, "nt", true)
		end

		-- In buffers where 'noexpandtab' is set (ie. hard tabs are in use), <Tab>:
		--
		--    - Inserts a tab on the left (for indentation).
		--    - Inserts spaces everywhere else (for alignment).
		--
		-- For other buffers (ie. where 'expandtab' applies), we use spaces everywhere.
		local smart_tab = function(opts)
			local keys = nil
			if vim.o.expandtab then
				keys = "<Tab>" -- Neovim will insert spaces.
			else
				local col = column()
				local line = vim.api.nvim_get_current_line()
				local prefix = line:sub(1, col)
				local in_leading_indent = prefix:find("^%s*$")
				if in_leading_indent then
					keys = "<Tab>" -- Neovim will insert a hard tab.
				else
					-- virtcol() returns last column occupied, so if cursor is on a
					-- tab it will report `actual column + tabstop` instead of `actual
					-- column`. So, get last column of previous character instead, and
					-- add 1 to it.
					local sw = shift_width()
					local previous_char = prefix:sub(#prefix, #prefix)
					local previous_column = #prefix - #previous_char + 1
					local current_column = vim.fn.virtcol({ vim.fn.line("."), previous_column }) + 1
					local remainder = (current_column - 1) % sw
					local move = remainder == 0 and sw or sw - remainder
					keys = (" "):rep(move)
				end
			end

			vim.api.nvim_feedkeys(rhs(keys), "nt", true)
		end

		local select_next_item = function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			else
				fallback()
			end
		end

		local select_prev_item = function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			else
				fallback()
			end
		end

		-- Until https://github.com/hrsh7th/nvim-cmp/issues/1716
		-- (cmp.ConfirmBehavior.MatchSuffix) gets implemented, use this local wrapper
		-- to choose between `cmp.ConfirmBehavior.Insert` and
		-- `cmp.ConfirmBehavior.Replace`:
		local confirm = function(entry)
			local behavior = cmp.ConfirmBehavior.Replace
			if entry then
				local completion_item = entry.completion_item
				local newText = ""
				if completion_item.textEdit then
					newText = completion_item.textEdit.newText
				elseif type(completion_item.insertText) == "string" and completion_item.insertText ~= "" then
					newText = completion_item.insertText
				else
					newText = completion_item.word or completion_item.label or ""
				end

				-- How many characters will be different after the cursor position if we
				-- replace?
				local diff_after = math.max(0, entry.replace_range["end"].character + 1) - entry.context.cursor.col

				-- Does the text that will be replaced after the cursor match the suffix
				-- of the `newText` to be inserted? If not, we should `Insert` instead.
				if entry.context.cursor_after_line:sub(1, diff_after) ~= newText:sub(-diff_after) then
					behavior = cmp.ConfirmBehavior.Insert
				end
			end
			cmp.confirm({ select = true, behavior = behavior })
		end
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
					if has_luasnip then
						luasnip.lsp_expand(args.body)
					end
				end,
			},
			-- Windows for autocompletion
			window = {
				completion = cmp.config.window.bordered(),
				documentation = cmp.config.window.bordered(),
			},
			-- keymappings for completions
			mapping = cmp.mapping.preset.insert({
				["<CR>"] = cmp.mapping.confirm({ select = false }), -- confirm selection
				["<BS>"] = cmp.mapping(function(_fallback)
					smart_bs()
				end, { "i", "s" }),

				["<C-b>"] = cmp.mapping.scroll_docs(-4),

				-- Choose a choice using vim.ui.select (ugh);
				-- prettier would be a pop-up, but it will require a bit of config:
				-- https://github.com/L3MON4D3/LuaSnip/wiki/Misc#choicenode-popup
				-- ['<C-u>'] = require('luasnip.extras.select_choice'),

				["<C-e>"] = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.close()
					elseif has_luasnip and luasnip.choice_active() then
						luasnip.jump(1)
					else
						fallback()
					end
				end, { "i", "s" }),

				["<C-f>"] = cmp.mapping.scroll_docs(4),
				["<C-j>"] = cmp.mapping(select_next_item),
				["<Down>"] = cmp.mapping(select_next_item),
				["<C-k>"] = cmp.mapping(select_prev_item),
				["<Up>"] = cmp.mapping(select_prev_item),

				["<C-y>"] = cmp.mapping(function(fallback)
					if cmp.visible() then
						local entry = cmp.get_selected_entry()
						confirm(entry)
					else
						fallback()
					end
				end, { "i", "s" }),

				["<S-Tab>"] = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.select_prev_item()
					elseif has_luasnip and in_snippet() and luasnip.jumpable(-1) then
						luasnip.jump(-1)
					elseif in_leading_indent() then
						smart_bs(true) -- true means to dedent
					elseif in_whitespace() then
						smart_bs()
					else
						fallback()
					end
				end, { "i", "s" }),

				["<Tab>"] = cmp.mapping(function(_fallback)
					if cmp.visible() then
						-- If there is only one completion candidate, use it.
						local entries = cmp.get_entries()
						if #entries == 1 then
							confirm(entries[1])
						else
							cmp.select_next_item()
						end
					elseif has_luasnip and luasnip.expand_or_locally_jumpable() then
						luasnip.expand_or_jump()
					elseif in_whitespace() then
						smart_tab()
					else
						cmp.complete()
					end
				end, { "i", "s" }),
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

		-- -- resizing windows only if cmp is not open
		local keymap = vim.keymap.set

		local function resize_if_no_cmp(direction)
			return function()
				if not cmp.visible() then
					if direction == "up" then
						vim.cmd("resize +2")
					elseif direction == "down" then
						vim.cmd("resize -2")
					elseif direction == "left" then
						vim.cmd("vertical resize +2")
					elseif direction == "right" then
						vim.cmd("vertical resize -2")
					end
				else
					-- Optional: fallback to <Tab> or do nothing
					-- You can log or just ignore it silently
				end
			end
		end

		keymap("n", "<Tab>k", resize_if_no_cmp("up"), { desc = "resize up" })
		keymap("n", "<Tab>j", resize_if_no_cmp("down"), { desc = "resize down" })
		keymap("n", "<Tab>h", resize_if_no_cmp("left"), { desc = "resize left" })
		keymap("n", "<Tab>l", resize_if_no_cmp("right"), { desc = "resize right" })

		-- Only show ghost text at word boundaries, not inside keywords. Based on idea
		-- from: https://github.com/hrsh7th/nvim-cmp/issues/2035#issuecomment-2347186210

		local config = require("cmp.config")

		local toggle_ghost_text = function()
			if vim.api.nvim_get_mode().mode ~= "i" then
				return
			end

			local cursor_column = vim.fn.col(".")
			local current_line_contents = vim.fn.getline(".")
			local character_after_cursor = current_line_contents:sub(cursor_column, cursor_column)

			local should_enable_ghost_text = character_after_cursor == ""
				or vim.fn.match(character_after_cursor, [[\k]]) == -1

			local current = config.get().experimental.ghost_text
			if current ~= should_enable_ghost_text then
				config.set_global({
					experimental = {
						ghost_text = should_enable_ghost_text,
					},
				})
			end
		end

		vim.api.nvim_create_autocmd({ "InsertEnter", "CursorMovedI" }, {
			callback = toggle_ghost_text,
		})
	end,
}

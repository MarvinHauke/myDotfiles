return {
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		dependencies = { "hrsh7th/nvim-cmp" },
		enabled = true,
		config = function()
			local npairs = require("nvim-autopairs")
			local Rule = require("nvim-autopairs.rule")
			local cond = require("nvim-autopairs.conds")

			-- Main setup with enhanced options
			npairs.setup({
				check_ts = true, -- Enable treesitter integration
				ts_config = {
					lua = { "string" }, -- Don't add pairs in lua string treesitter nodes
					javascript = { "template_string" }, -- Don't add pairs in JS template strings
					java = false, -- Don't check treesitter on java
				},
				disable_filetype = { "TelescopePrompt", "vim" },
				disable_in_macro = false, -- Disable when recording or executing a macro
				disable_in_visualblock = false, -- Disable when insert after visual block mode
				disable_in_replace_mode = true, -- Disable in replace mode
				ignored_next_char = [=[[%w%%%'%[%"%.%`%$]]=],
				enable_moveright = true, -- Enable moving right when closing pair
				enable_afterquote = true, -- Add bracket pairs after quote
				enable_check_bracket_line = true, -- Check bracket in same line
				enable_bracket_in_quote = true, -- Enable bracket in quote
				enable_abbr = false, -- Trigger abbreviation
				break_undo = true, -- Switch for basic rule break undo sequence
				check_comma = true, -- Check comma in next char
				map_cr = true, -- Map <CR> key
				map_bs = true, -- Map <BS> key
				map_c_h = false, -- Map <C-h> key to delete pair
				map_c_w = false, -- Map <C-w> key to delete pair if possible
			})

			-- Custom rules for specific languages

			-- Add spaces inside function calls: func( | ) -> func(  |  )
			npairs.add_rule(
				Rule("(", ")")
					:with_pair(cond.not_filetypes({ "lua" }))
					:with_move(cond.none())
					:with_cr(cond.none())
					:with_del(cond.none())
			)

			-- Add rule for triple quotes in Python
			npairs.add_rule(Rule('"""', '"""', "python"))
			npairs.add_rule(Rule("'''", "'''", "python"))

			-- Add rule for JSX/TSX fragments
			npairs.add_rule(Rule("<", ">")
				:with_pair(cond.before_regex("%a+:?:?$", 1))
				:with_move(function(opts)
					return opts.char == ">"
				end)
				:only_cr(cond.none())
				:use_key(">"))

			-- Add rule for template literals in JavaScript/TypeScript
			npairs.add_rule(Rule("`", "`", { "javascript", "typescript" }))

			-- Add rule for raw strings in Rust
			npairs.add_rule(Rule('r"', '"', "rust"))

			-- Add rule for pipe operators in some languages
			npairs.add_rule(Rule("|", "|", { "rust", "haskell" }):with_move(cond.none()):with_cr(cond.none()))

			-- Enhanced CMP integration
			local cmp_autopairs = require("nvim-autopairs.completion.cmp")
			local cmp = require("cmp")

			cmp.event:on(
				"confirm_done",
				cmp_autopairs.on_confirm_done({
					filetypes = {
						-- Disable for specific filetypes
						["*"] = {
							["("] = {
								kind = {
									cmp.lsp.CompletionItemKind.Function,
									cmp.lsp.CompletionItemKind.Method,
								},
								handler = function(char, item, bufnr, rules, commit_character)
									-- Custom handler for function/method completions
									-- Add parentheses with cursor inside for functions
									if item.insertText and item.insertText:match(".*%(.*%)$") then
										-- Function already has parentheses, don't add more
										return
									end
									-- Default behavior
									cmp_autopairs.on_confirm_done()(char, item, bufnr, rules, commit_character)
								end,
							},
						},
						-- Language-specific overrides
						sh = false, -- Disable for shell scripts
					},
				})
			)

			-- Fast wrap feature keybindings
			local remap = vim.api.nvim_set_keymap
			local npairs_utils = require("nvim-autopairs.utils")

			-- Fast wrap with Alt-e
			remap("i", "<M-e>", "v:lua.MPairs.autopairs_fast_wrap()", { expr = true, noremap = true })

			-- Custom function for fast wrap
			_G.MPairs = {}
			_G.MPairs.autopairs_fast_wrap = function()
				local npairs = require("nvim-autopairs")
				local utils = require("nvim-autopairs.utils")
				local char = utils.get_next_char()
				if char:match("%w") then
					return "<M-e>"
				end
				return npairs.autopairs_fast_wrap()
			end

			-- Optional: Add endwise support for Ruby, Lua, etc.
			-- Uncomment if you want auto-completion for 'end' statements
			local endwise = require("nvim-autopairs.ts-rule").endwise
			npairs.add_rule(endwise("then$", "end", "lua", "if_statement"))
			npairs.add_rule(endwise("do$", "end", "lua", "function_definition"))
		end,
	},
}

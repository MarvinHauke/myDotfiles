return {
	"stevearc/conform.nvim",
	lazy = true,
	event = { "BufReadPre", "BufNewFile" }, -- to disable, comment this out
	enabled = true,
	config = function()
		local conform = require("conform")
		conform.setup({
			formatters_by_ft = {
				javascript = { "prettierd" },
				typescript = { "prettierd" },
				javascriptreact = { "prettierd" },
				typescriptreact = { "prettierd" },
				svelte = { "prettierd" },
				css = { "prettierd" },
				html = { "prettierd" },
				json = { "jq", "prettierd" },
				yaml = { "prettierd" },
				markdown = { "prettierd" },
				graphql = { "prettierd" },
				lua = { "stylua" },
				python = { "isort", "black" },
				xml = { "xmlformatter" },
				zsh = { "shfmt", "shellharden" },
				sh = { "shfmt", "shellharden" },
				bash = { "shfmt", "shellharden" },
				cpp = { "clang-format" },
				c = { "clang-format" },
				cmake = { "cmake_format" },
				-- make = { "shfmt" }, -- Don´t format makefiles!!!
				rust = { "rustfmt" },
				go = { "gofmt" },
				arduino = { "clang-format" },
			},

			-- Keymaps for manualy formatting
			vim.keymap.set({ "n", "v" }, "<leader>fom", function()
				conform.format({
					lsp_fallback = true,
					async = true,
					timeout_ms = 500,
				})
			end, { desc = "format file with conform" }),

			-- Format on save (skips when vim.g.disable_autoformat is set)
			format_on_save = function(bufnr)
				if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
					return
				end
				return {
					lsp_fallback = true,
					async = false,
					timeout_ms = 1000,
				}
			end,
		})

		-- Toggle format-on-save: bang (!) toggles for the current buffer only
		vim.api.nvim_create_user_command("FormatToggle", function(args)
			if args.bang then
				vim.b.disable_autoformat = not vim.b.disable_autoformat
				print("Format on save (buffer): " .. (vim.b.disable_autoformat and "OFF" or "ON"))
			else
				vim.g.disable_autoformat = not vim.g.disable_autoformat
				print("Format on save (global): " .. (vim.g.disable_autoformat and "OFF" or "ON"))
			end
		end, { desc = "Toggle format-on-save", bang = true })

		vim.keymap.set("n", "<leader>fot", "<cmd>FormatToggle<cr>", { desc = "toggle format on save" })
	end,
}

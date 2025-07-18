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

			-- Format on save
			format_on_save = {
				lsp_fallback = true,
				async = false,
				timeout_ms = 1000,
			},
		})
	end,
}

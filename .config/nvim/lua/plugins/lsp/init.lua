return {
	-- Mason must be loaded first
	{
		"mason-org/mason.nvim",
		config = function()
			require("mason").setup()
		end,
	},

	-- Mason-lspconfig depends on mason
	{
		"mason-org/mason-lspconfig.nvim",
		dependencies = { "mason-org/mason.nvim" },
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"lemminx",
					"marksman",
					"powershell_es",
					"quick_lint_js",
					"cssls",
					"html",
					"svelte",
					"rust_analyzer",
					"cmake",
				},
				automatic_installation = { exclude = { "jsonls" } },
			})
		end,
	},

	-- Mason-tool-installer depends on mason
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = { "mason-org/mason.nvim" },
		config = function()
			require("mason-tool-installer").setup({
				ensure_installed = {
					"prettier",
					"stylua",
					"isort",
					"black",
					"pylint",
					"eslint_d",
					"shellharden",
					"shfmt",
					"shellcheck",
				},
			})
		end,
	},

	-- LSP Config depends on all the above
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"mason-org/mason.nvim",
			"mason-org/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			"hrsh7th/cmp-nvim-lsp",
			"b0o/schemastore.nvim",
			"j-hui/fidget.nvim",
			"folke/neodev.nvim",
		},
		config = function()
			-- Fidget setup
			require("fidget").setup({})

			-- Common LSP configuration
			local lsp_capabilities = require("cmp_nvim_lsp").default_capabilities()

			-- Common on_attach function
			local lsp_attach = function(client, bufnr)
				local map = function(mode, keys, func, desc)
					vim.keymap.set(mode, keys, func, {
						noremap = true,
						silent = true,
						buffer = bufnr,
						desc = desc,
					})
				end

				-- LSP: Navigation
				map("n", "<leader>gd", vim.lsp.buf.definition, "Go to Definition")
				map("n", "<leader>gD", vim.lsp.buf.declaration, "Go to Declaration")
				map("n", "<leader>gi", vim.lsp.buf.implementation, "Go to Implementation")
				map("n", "<leader>gt", vim.lsp.buf.type_definition, "Go to Type Definition")
				map("n", "<leader>gr", vim.lsp.buf.references, "Show References")
				map("n", "<leader>gs", vim.lsp.buf.signature_help, "Signature Help")
				map("n", "<leader>k", vim.lsp.buf.hover, "Hover Info")

				-- LSP: Actions
				map("n", "<leader>rr", vim.lsp.buf.rename, "Rename Symbol")
				map("n", "<leader>ga", vim.lsp.buf.code_action, "Code Action")
				map("n", "<leader>ca", vim.lsp.buf.code_action, "LSP Code Action")

				-- Format (safe fallback for async)
				map({ "n", "v" }, "<leader>gf", function()
					if client.supports_method("textDocument/formatting") then
						vim.lsp.buf.format({ async = true })
					end
				end, "Format File")

				-- LSP: Diagnostics (Updated)
				map("n", "<leader>gl", vim.diagnostic.open_float, "Show Line Diagnostics")
				map("n", "<leader>gp", function()
					vim.diagnostic.jump({ count = -1 })
				end, "Previous Diagnostic")
				map("n", "<leader>gn", function()
					vim.diagnostic.jump({ count = 1 })
				end, "Next Diagnostic")
				map("n", "<leader>j", function()
					vim.diagnostic.open_float(nil, { focusable = false, border = "rounded" })
				end, "Show Line Diagnostics (rounded)")

				-- LSP: Symbols
				map("n", "<leader>tr", vim.lsp.buf.document_symbol, "Document Symbols")
			end

			-- Store common config for reuse
			_G.lsp_common = {
				lsp_attach = lsp_attach,
				lsp_capabilities = lsp_capabilities,
			}

			-- Load language-specific configurations
			require("plugins.lsp.lua")
			require("plugins.lsp.python")
			require("plugins.lsp.rust")
			require("plugins.lsp.c")
			require("plugins.lsp.bash")
			require("plugins.lsp.web")
			require("plugins.lsp.markup")
			require("plugins.lsp.powershell")
			require("plugins.lsp.cmake")

			-- Auto-detect shell script filetypes
			vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
				pattern = { ".bashrc", ".bash_profile", ".bash_aliases", ".zshrc", ".profile", ".bash_logout" },
				callback = function()
					vim.bo.filetype = "bash"
				end,
			})
		end,
	},
}

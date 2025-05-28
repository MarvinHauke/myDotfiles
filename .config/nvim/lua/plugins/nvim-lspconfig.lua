return {
	-- LSP Configuration
	"neovim/nvim-lspconfig", -- https://github.com/neovim/nvim-lspconfig
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		-- LSP Management
		"mason-org/mason.nvim", -- https://github.com/williamboman/mason.nvim
		"mason-org/mason-lspconfig.nvim", -- https://github.com/williamboman/mason-lspconfig.nvim
		"WhoIsSethDaniel/mason-tool-installer.nvim", -- https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim
		"hrsh7th/cmp-nvim-lsp", -- LSP completion capabilities
		"b0o/schemastore.nvim", -- https://github.com/b0o/SchemaStore.nvim

		-- Useful status updates for LSP
		"j-hui/fidget.nvim", -- https://github.com/j-hui/fidget.nvim

		-- Additional lua configuration, makes nvim stuff amazing!
		"folke/neodev.nvim", -- https://github.com/folke/neodev.nvim
	},
	config = function()
		require("mason").setup()
		require("mason-lspconfig").setup({
			ensure_installed = {
				-- Update this list to the language servers you need installed
				-- "lua_ls",
				-- "clangd", -- provided systemwide Not by Mason
				"lemminx",
				"marksman",
				"powershell_es",
				"lemminx",
				"quick_lint_js",
				"cssls",
				"html",
				"svelte",
				"rust_analyzer",
				"cmake",
			},
			automatic_installation = { exclude = { "jsonls" } },
		})
		local lspconfig = require("lspconfig")
		local lsp_capabilities = require("cmp_nvim_lsp").default_capabilities() -- INFO Search for difference between default_capabilities and normal capabilities
		local mason_tool_installer = require("mason-tool-installer")
		require("fidget").setup({})

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

			-- LSP: Diagnostics
			map("n", "<leader>gl", vim.diagnostic.open_float, "Show Line Diagnostics")
			map("n", "<leader>gp", vim.diagnostic.goto_prev, "Previous Diagnostic")
			map("n", "<leader>gn", vim.diagnostic.goto_next, "Next Diagnostic")
			map("n", "<leader>j", function()
				vim.diagnostic.open_float(nil, { focusable = false, border = "rounded" })
			end, "Show Line Diagnostics (rounded)")

			-- LSP: Symbols
			map("n", "<leader>tr", vim.lsp.buf.document_symbol, "Document Symbols")
		end

		-- Mason tool installer
		mason_tool_installer.setup({
			ensure_installed = {
				"prettier", -- prettier formatter
				"stylua", -- lua formatter
				"isort", -- python formatter
				"black", -- python formatter
				"pylint", -- python linter
				"prittier", -- js formatter
				"eslint_d", -- js linter
				"shellharden",
				"shfmt",
				"shellcheck",
			},
		})
		local util = require("lspconfig.util")

		-- Lua LSP settings
		lspconfig.lua_ls.setup({
			capabilities = lsp_capabilities,
			on_attach = lsp_attach,
			settings = { -- custom settings for lua
				Lua = {
					-- make language server recognize the `vim` global
					diagnostics = {
						globals = { "vim" },
					},
					workspace = {
						-- make language server aware of runtime files
						[vim.fn.expand("$VIMRUNTIME/lua")] = true,
						[vim.fn.stdpath("config") .. "/lua"] = true,
					},
				},
			},
		})

		-- Bash LSP settings
		lspconfig.bashls.setup({
			capabilities = lsp_capabilities,
			on_attach = lsp_attach,
			cmd = { "bash-language-server", "start" },
			filetypes = { "bash", "sh" },
			root_dir = function(fname)
				-- Try to find a .git or fallback to CWD
				return util.root_pattern(".git")(fname) or vim.fn.getcwd()
			end,
			settings = {
				bashIde = {
					globPattern = "*@(.sh|.inc|.bash|.command)",
				},
			},
		})

		-- PowerShell LSP settings
		lspconfig.powershell_es.setup({
			capabilities = lsp_capabilities,
			on_attach = lsp_attach,
			settings = { -- custom settings for powershell
				powershell = {
					codeFormatting = {
						Preset = "OTBS",
					},
				},
			},
		})

		-- HTML LSP settings
		lspconfig.html.setup({
			capabilities = lsp_capabilities,
			on_attach = lsp_attach,
		})

		-- CSS LSP settings
		lspconfig.cssls.setup({
			capabilities = lsp_capabilities,
			on_attach = lsp_attach,
		})

		-- C++ LSP settings
		lspconfig.clangd.setup({
			on_attach = lsp_attach,
			capabilities = lsp_capabilities,
			root_dir = util.root_pattern("compile_commands.json", "compile_flags.txt", ".git"),
			cmd = {
				"clangd",
				"--background-index",
				"--clang-tidy",
				"--completion-style=detailed",
				"--pch-storage=memory",
				"--all-scopes-completion",
			},
		})

		-- Python LSP settings
		vim.lsp.config("ruff", {
			on_attach = lsp_attach,
			capabilities = lsp_capabilities,
			settings = {},
		})

		lspconfig.rust_analyzer.setup({
			capabilities = lsp_capabilities,
			on_attach = lsp_attach,
			filetypes = { "rust" },
			settings = {
				["rust-analyzer"] = {
					checkOnSave = {
						command = "clippy",
					},
					cargo = {
						allFeatures = true,
						rundBuildScripts = true,
					},
					procMacro = {
						enable = true,
					},
				},
			},
			root_dir = function(fname)
				return util.root_pattern("Cargo.toml", "rust-project.json")(fname) or vim.fn.getcwd() -- Fallback to the current working directory
			end,
		})

		-- JS/TS LSP settings
		lspconfig.ts_ls.setup({
			capabilities = lsp_capabilities,
			on_attach = lsp_attach,
		})

		-- Yaml LSP settings
		lspconfig.yamlls.setup({
			capabilities = lsp_capabilities,
			on_attach = lsp_attach,
			settings = {
				yaml = {
					schemaStore = {
						-- You must disable built-in schemaStore support if you want to use
						-- this plugin and its advanced options like `ignore`.
						enable = false,
						-- Avoid TypeError: Cannot read properties of undefined (reading 'length')
						url = "",
					},
					schemas = require("schemastore").yaml.schemas(),
				},
			},
		})
		-- JSON LSP settings
		lspconfig.jsonls.setup({
			cmd = { "vscode-json-language-server", "--stdio" },
			filetypes = { "json", "jsonc" },
			capabilities = lsp_capabilities,
			on_attach = lsp_attach,
			settings = {
				json = {
					schemas = require("schemastore").json.schemas(),
					validate = { enable = true },
				},
			},
		})

		-- CMakeLists
		lspconfig.cmake.setup({
			capabilities = lsp_capabilities,
			on_attach = lsp_attach,
		})
	end,
}

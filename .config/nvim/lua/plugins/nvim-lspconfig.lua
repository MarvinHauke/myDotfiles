return {
	-- LSP Configuration
	"neovim/nvim-lspconfig", -- https://github.com/neovim/nvim-lspconfig
	event = "VeryLazy",
	dependencies = {
		-- LSP Management
		"mason-org/mason.nvim", -- https://github.com/williamboman/mason.nvim
		"mason-org/mason-lspconfig.nvim", -- https://github.com/williamboman/mason-lspconfig.nvim
		"WhoIsSethDaniel/mason-tool-installer.nvim", -- https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim
		"hrsh7th/cmp-nvim-lsp", -- LSP completion capabilities

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
				"bashls",
				-- "lua_ls",
				-- "clangd", -- provided systemwide Not by Mason
				"jsonls",
				"lemminx",
				"marksman",
				"powershell_es",
				"lemminx",
				"quick_lint_js",
				"cssls",
				"html",
				"svelte",
				"rust_analyzer",
				"efm",
				"cmake",
			},
			automatic_installation = true,
		})
		local lspconfig = require("lspconfig")
		local lsp_capabilities = require("cmp_nvim_lsp").default_capabilities() -- INFO Search for difference between default_capabilities and normal capabilities
		local mason_tool_installer = require("mason-tool-installer")
		require("fidget").setup({})

		-- Keybindings for LSPs (works only if lsp is attached to buffer)
		local lsp_attach = function(client, bufnr)
			local keymap = vim.keymap.set
			local opts = { noremap = true, silent = true, buffer = bufnr }

			-- LSP navigation
			keymap(
				"n",
				"<leader>gd",
				vim.lsp.buf.definition,
				vim.tbl_extend("force", opts, { desc = "Go to Definition" })
			)
			keymap(
				"n",
				"<leader>gD",
				vim.lsp.buf.declaration,
				vim.tbl_extend("force", opts, { desc = "Go to Declaration" })
			)
			keymap(
				"n",
				"<leader>gi",
				vim.lsp.buf.implementation,
				vim.tbl_extend("force", opts, { desc = "Go to Implementation" })
			)
			keymap(
				"n",
				"<leader>gt",
				vim.lsp.buf.type_definition,
				vim.tbl_extend("force", opts, { desc = "Go to Type Definition" })
			)
			keymap(
				"n",
				"<leader>gr",
				vim.lsp.buf.references,
				vim.tbl_extend("force", opts, { desc = "Show References" })
			)
			keymap(
				"n",
				"<leader>gs",
				vim.lsp.buf.signature_help,
				vim.tbl_extend("force", opts, { desc = "Signature Help" })
			)

			-- Actions
			keymap("n", "<leader>rr", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "Rename Symbol" }))
			keymap({ "n", "v" }, "<leader>gf", function()
				vim.lsp.buf.format({ async = true })
			end, vim.tbl_extend("force", opts, { desc = "Format File" }))
			keymap("n", "<leader>ga", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "Code Action" }))
			keymap(
				"n",
				"<leader>ca",
				vim.lsp.buf.code_action,
				vim.tbl_extend("force", opts, { desc = "LSP Code Action" })
			) -- optional dup

			-- Diagnostics
			keymap(
				"n",
				"<leader>gl",
				vim.diagnostic.open_float,
				vim.tbl_extend("force", opts, { desc = "Show Line Diagnostics" })
			)
			keymap(
				"n",
				"<leader>gp",
				vim.diagnostic.goto_prev,
				vim.tbl_extend("force", opts, { desc = "Previous Diagnostic" })
			)
			keymap(
				"n",
				"<leader>gn",
				vim.diagnostic.goto_next,
				vim.tbl_extend("force", opts, { desc = "Next Diagnostic" })
			)
			keymap("n", "<leader>j", function()
				vim.diagnostic.open_float(nil, { focusable = false, border = "rounded" })
			end, vim.tbl_extend("force", opts, { desc = "Show Line Diagnostics (rounded)" }))

			-- Misc
			keymap(
				"n",
				"<leader>tr",
				vim.lsp.buf.document_symbol,
				vim.tbl_extend("force", opts, { desc = "Document Symbols" })
			)
			keymap("n", "<leader>k", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Hover Info" }))
		end

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
			filetypes = { "sh", "bash", "dosbatch" }, -- Standard filetypes
			root_dir = function(fname)
				-- Match `.{foo}rc` files and attach the LSP
				if fname:match(".*%.%w+rc$") then
					return vim.fn.getcwd() -- Attach in current directory for dotfiles
				end
				return vim.fs.dirname(fname)
			end,
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

		-- C++ LSP settings
		lspconfig.clangd.setup({
			on_attach = lsp_attach,
			capabilities = lsp_capabilities,
			root_dir = require("lspconfig.util").root_pattern("compile_commands.json", "compile_flags.txt", ".git"),
			cmd = {
				"clangd",
				"--background-index",
				"--clang-tidy",
				"--completion-style=detailed",
				"--pch-storage=memory",
				"--all-scopes-completion",
			},
		})

		-- -- Python LSP settings (removed in favor of ruff)
		lspconfig.pyright.setup({
			capabilities = lsp_capabilities,
			on_attach = lsp_attach,
		})
		vim.lsp.config("ruff", {
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

		-- JSON lsp
		lspconfig.jsonls.setup({
			capabilities = lsp_capabilities,
			on_attach = lsp_attach,
			settings = {
				json = {
					-- Schemas https://www.schemastore.org
					schemas = {
						{
							fileMatch = { "package.json" },
							url = "https://json.schemastore.org/package.json",
						},
						{
							fileMatch = { "tsconfig*.json" },
							url = "https://json.schemastore.org/tsconfig.json",
						},
						{
							fileMatch = {
								".prettierrc",
								".prettierrc.json",
								"prettier.config.json",
							},
							url = "https://json.schemastore.org/prettierrc.json",
						},
						{
							fileMatch = { ".eslintrc", ".eslintrc.json" },
							url = "https://json.schemastore.org/eslintrc.json",
						},
						{
							fileMatch = {
								".babelrc",
								".babelrc.json",
								"babel.config.json",
							},
							url = "https://json.schemastore.org/babelrc.json",
						},
						{
							fileMatch = { "lerna.json" },
							url = "https://json.schemastore.org/lerna.json",
						},
						{
							fileMatch = { "now.json", "vercel.json" },
							url = "https://json.schemastore.org/now.json",
						},
						{
							fileMatch = {
								".stylelintrc",
								".stylelintrc.json",
								"stylelint.config.json",
							},
							url = "http://json.schemastore.org/stylelintrc.json",
						},
					},
				},
			},
		})

		-- CMakeLists
		lspconfig.cmake.setup({
			capabilities = lsp_capabilities,
			on_attach = lsp_attach,
		})

		-- Define individual languages for efm lsp
		local checkmake = {
			lintCommand = "checkmake",
			lintStdin = true,
			lintFormats = { "%f:%l:%c: %m" },
		}

		local shfmt = {
			formatCommand = "shfmt -i 2 -ci -sr",
			formatStdin = true,
		}

		local shellcheck = {
			lintCommand = "shellcheck",
			lintStdin = true,
			lintFormats = { "%f:%l:%c: %m" },
		}

		local shellharden = {
			formatCommand = "shellharden --transform",
			formatStdin = true,
		}

		local languages = {
			zsh = { shellcheck, shfmt, shellharden },
			make = { checkmake }, -- only linting for Makefiles
			sh = { shellharden, shfmt, shellcheck }, -- formatting and linting for shell
		}

		-- Setup EFM with structured config
		lspconfig.efm.setup({
			init_options = {
				documentFormatting = true,
				hover = true,
				completion = true,
				diagnostics = true,
			},
			filetypes = vim.tbl_keys(languages),
			settings = {
				rootMarkers = { ".git/" },
				languages = languages,
			},
			capabilities = {
				offsetEncoding = { "utf-8" },
			},
			on_attach = lsp_attach,
		})
	end,
}

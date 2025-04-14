return {
	-- LSP Configuration
	"neovim/nvim-lspconfig", -- https://github.com/neovim/nvim-lspconfig
	event = "VeryLazy",
	dependencies = {
		-- LSP Management
		"williamboman/mason.nvim", -- https://github.com/williamboman/mason.nvim
		"williamboman/mason-lspconfig.nvim", -- https://github.com/williamboman/mason-lspconfig.nvim
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
				"lua_ls",
				"clangd",
				"jsonls",
				"lemminx",
				"marksman",
				"powershell_es",
				"lemminx",
				"quick_lint_js",
				"cssls",
				"tailwindcss",
				"html",
				"svelte",
				"rust_analyzer",
				"ruff",
			},
			automatic_installation = true,
		})
		local lspconfig = require("lspconfig")
		local lsp_capabilities = require("cmp_nvim_lsp").default_capabilities() -- INFO Search for difference between default_capabilities and normal capabilities
		local mason_tool_installer = require("mason-tool-installer")
		require("fidget").setup({})

		-- Keybindings for LSPs (works only if lsp is attached to buffer)
		local lsp_attach =
			function(client, bufnr)
				vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "LSP Code Action" })
				vim.keymap.set({ "n", "v" }, "<leader>j", function()
					vim.diagnostic.open_float(nil, { focusable = false, border = "rounded" })
				end, { desc = "Show Line Diagnostics" })
			end,
			-- Call setup on each LSP server
			require("mason-lspconfig").setup_handlers({
				function(server_name)
					lspconfig[server_name].setup({
						on_attach = lsp_attach,
						capabilities = lsp_capabilities,
					})
				end,
			})

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
			filetypes = { "sh", "zsh", "bash", "dosbatch" }, -- Standard filetypes
			root_dir = function(fname)
				-- Match `.{foo}rc` files and attach the LSP
				if fname:match(".*%.%w+rc$") then
					return vim.fn.getcwd() -- Attach in current directory for dotfiles
				end
				return lspconfig.util.find_git_ancestor(fname) -- Otherwise, use Git root
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

		-- ccls LSP settings
		lspconfig.ccls.setup({
			init_options = {
				compilationDatabaseDirectory = ".pio/build/",
				index = { threads = 4 },
				clang = {
					extraArgs = { "-I", ".pio/libdeps/", "-I", ".pio/build/" },
					resourceDir = "",
				},
			},
		})

		-- C++ LSP settings
		lspconfig.clangd.setup({
			on_attach = lsp_attach,
			capabilities = lsp_capabilities,
			root_dir = require("lspconfig.util").root_pattern("compile_commands.json", "compile_flags.txt", ".git"),
			cmd = {
				"clangd",
				"--background-index",
				"-j=12",
				"--query-driver=**",
				"--clang-tidy",
				"--all-scopes-completion",
				"--cross-file-rename",
				"--completion-style=detailed",
				"--header-insertion-decorators",
				"--header-insertion=iwyu",
				"--pch-storage=memory",
				"--suggest-missing-includes",
				-- "--clang-format-style=LLVM", -- adds the prefered formatting style change this to Google|Chromium|GNU|Microsoft
			},
		})

		-- Python ruff linter
		lspconfig.ruff.setup({
			capabilities = lsp_capabilities,
			on_attach = lsp_attach,
		})

		-- -- Python LSP settings (removed in favor of ruff)
		-- lspconfig.pyright.setup({
		-- 	capabilities = lsp_capabilities,
		-- 	on_attach = lsp_attach,
		-- })

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

		-- Makefile linting via efm-lsp
		lspconfig.efm.setup({
			init_options = { documentFormatting = true },
			filetypes = { "make" },
			settings = {
				languages = {
					make = {
						{
							formatCommand = "checkmake",
							lintCommand = "checkmake",
							lintStdin = true,
							lintFormats = { "%f:%l:%c: %m" },
						},
					},
				},
			},
			capabilities = {
				offsetEncoding = { "utf-8" },
			},
		})
	end,
}

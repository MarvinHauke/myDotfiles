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
				"arduino_language_server",
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
			},
			automatic_installation = true,
		})
		local lspconfig = require("lspconfig")
		local lsp_capabilities = require("cmp_nvim_lsp").default_capabilities() -- INFO Search for difference between default_capabilities and normal capabilities
		local mason_tool_installer = require("mason-tool-installer")
		require("fidget").setup({})

		-- Keybindings for LSPs (works only if lsp is attached to buffer)
		local lsp_attach = function(client, bufnr)
			vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "LSP Code Action" })
		end

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
			settings = { -- custom settings for bash
				bash = {
					-- make language server recognize the `vim` global
					filetypes = { "sh", "zsh" },
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
			},
		})
		--
		-- -- Arduino LSP settings
		-- -- When the arduino server starts in these directories, use the provided FQBN.
		-- -- Note that the server needs to start exactly in these directories.
		-- -- This example would require some extra modification to support applying the FQBN on subdirectories!

		--
		-- -- Define FQBN mappings for different projects
		-- local my_arduino_fqbn = {
		-- 	["teensy31"] = "teensy:avr:teensy31",
		-- 	["teensy41"] = "teensy:avr:teensy41",
		-- 	["esp32dev"] = "esp32:esp32:esp32",
		-- }
		--
		-- -- Default to Arduino Nano if no board is detected
		-- local DEFAULT_FQBN = "arduino:avr:nano"
		--
		-- -- Function to get the board from platformio.ini
		-- local function get_fqbn_from_pio()
		-- 	local ini_file = io.open("platformio.ini", "r")
		-- 	if not ini_file then
		-- 		return DEFAULT_FQBN
		-- 	end
		--
		-- 	for line in ini_file:lines() do
		-- 		local board = line:match("^%s*board%s*=%s*(%S+)")
		-- 		if board and my_arduino_fqbn[board] then
		-- 			ini_file:close()
		-- 			return my_arduino_fqbn[board]
		-- 		end
		-- 	end
		--
		-- 	ini_file:close()
		-- 	return DEFAULT_FQBN
		-- end
		--
		-- -- LSP Setup for Arduino
		-- lspconfig.arduino_language_server.setup({
		-- 	capabilities = lsp_capabilities,
		-- 	on_attach = lsp_attach,
		--
		-- 	on_new_config = function(config, root_dir)
		-- 		local fqbn = get_fqbn_from_pio()
		-- 		vim.notify(("Using FQBN: %q for project in %q"):format(fqbn, root_dir))
		--
		-- 		config.cmd = {
		-- 			"arduino-language-server",
		-- 			"-clangd",
		-- 			"/usr/bin/clangd", -- Ensure clangd is installed
		-- 			"-cli",
		-- 			"/opt/homebrew/bin/arduino-cli", -- Homebrew-installed Arduino CLI
		-- 			"-cli-config",
		-- 			"/Users/pforsten/Library/Arduino15/arduino-cli.yaml",
		-- 			"-fqbn",
		-- 			fqbn,
		-- 		}
		-- 	end,
		--
		-- 	filetypes = { "ino" },
		--
		-- 	root_dir = function(fname)
		-- 		return util.root_pattern("*.ino", "CMakeLists.txt", ".git", "platformio.ini")(fname) or vim.fn.getcwd() -- Fallback to the current working directory
		-- 	end,
		-- })

		lspconfig.rust_analyzer.setup({
			capabilities = lsp_capabilities,
			on_attach = lsp_attach,
			filetypes = { "rust" },
			root_dir = function(fname)
				return util.root_pattern("Cargo.toml", "rust-project.json")(fname) or vim.fn.getcwd() -- Fallback to the current working directory
			end,
			settings = {
				["rust-analyzer"] = {
					cargo = {
						allFreeArgs = true,
					},
				},
			},
		})
		-- JS LSP settings
		lspconfig.ts_ls.setup({
			capabilities = lsp_capabilities,
			on_attach = lsp_attach,
		})

		-- Python LSP settings
		lspconfig.pyright.setup({
			capabilities = lsp_capabilities,
			on_attach = lsp_attach,
		})
	end,
}

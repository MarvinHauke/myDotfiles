return {
	-- LSP Configuration
	"neovim/nvim-lspconfig", -- https://github.com/neovim/nvim-lspconfig
	event = "VeryLazy",
	dependencies = {
		-- LSP Management
		"williamboman/mason.nvim", -- https://github.com/williamboman/mason.nvim
		"williamboman/mason-lspconfig.nvim", -- https://github.com/williamboman/mason-lspconfig.nvim
		"WhoIsSethDaniel/mason-tool-installer.nvim",

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
				"quick_lint_js",
				"powershell_es",
				"lemminx",
				"cssls",
				"tailwindcss",
				"html",
				"svelte",
			},
			automatic_installation = true,
		})
		local lspconfig = require("lspconfig")
		local lsp_capabilities = require("cmp_nvim_lsp").default_capabilities() -- INFO Search for difference between default_capabilities and normal capabilities
		local mason_tool_installer = require("mason-tool-installer")
		require("fidget").setup({})

		local lsp_attach = function(client, bufnr)
			-- Create your attached keybindings here..
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

		-- C++ LSP settings
		lspconfig.clangd.setup({
			capabilities = lsp_capabilities,
			on_attach = lsp_attach,
		})

		-- Arduino LSP settings
		-- When the arduino server starts in these directories, use the provided FQBN.
		-- Note that the server needs to start exactly in these directories.
		-- This example would require some extra modification to support applying the FQBN on subdirectories!

		local my_arduino_fqbn = {
			-- Add other project-specific FQBNs here
			["/home/pforsten/Development/arduino/blink"] = "arduino:avr:nano",
			["/home/pforsten/Development/arduino/mbed"] = "arduino:mbed:nanorp2040connect",
			["/Users/pforsten/Development/arduino/stm32"] = "STMicroelectronics:stm32:BlackPill_F411CE",
			["/Users/pforsten/Development/arduino/teensy"] = "teensy:avr:teensy41",
			["/Users/pforsten/Development/arduino/esp32"] = "esp32:esp32:esp32",
		}

		-- Set default board to Arduino Nano
		local DEFAULT_FQBN = "arduino:avr:nano"

		local function get_fqbn_from_pio()
			local ini_file = io.open("platformio.ini", "r")
			if not ini_file then
				return DEFAULT_FQBN
			end

			for line in ini_file:lines() do
				local board = line:match("^%s*board%s*=%s*(%S+)")
				if board and my_arduino_fqbn[board] then
					ini_file:close()
					return my_arduino_fqbn[board]
				end
			end

			ini_file:close()
			return DEFAULT_FQBN
		end

		lspconfig.arduino_language_server.setup({
			capabilities = lsp_capabilities,
			on_attach = lsp_attach,
			filetypes = { "c", "cpp", "ino" },
			root_dir = function(fname)
				return lspconfig.util.root_pattern("CMakeLists.txt", ".git", "platformio.ini")(fname) or vim.fn.getcwd() -- Fallback to the current working directory
			end,
			on_new_config = function(config, root_dir)
				local fqbn = get_fqbn_from_pio()
				vim.notify(("Using FQBN: %q for project in %q"):format(fqbn, root_dir))

				config.cmd = {
					"arduino-language-server",
					"-clangd",
					"/usr/bin/clangd", -- Ensure clangd is installed
					"-cli",
					"/opt/homebrew/bin/arduino-cli", -- Homebrew-installed Arduino CLI
					"-cli-config",
					"/Users/pforsten/Library/Arduino15/arduino-cli.yaml",
					"-fqbn",
					fqbn,
				}
			end,
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

return {
	{
		"mfussenegger/nvim-dap",
		event = "VeryLazy",
		dependencies = {
			"rcarriga/nvim-dap-ui",
			"jay-babu/mason-nvim-dap.nvim",
			"williamboman/mason.nvim",
			"nvim-neotest/nvim-nio",
			"jbyuki/one-small-step-for-vimkind",
			"jedrzejboczar/nvim-dap-cortex-debug",
			{
				"theHamsta/nvim-dap-virtual-text", -- https://github.com/theHamsta/nvim-dap-virtual-text
				lazy = true,
				opts = {
					-- Display debug text as a comment
					commented = true,
					-- Customize virtual text
					display_callback = function(variable, buf, stackframe, node, options)
						if options.virt_text_pos == "inline" then
							return " = " .. variable.value
						else
							return variable.name .. " = " .. variable.value
						end
					end,
				},
			},
		},

		config = function()
			local dap = require("dap")
			local dapui = require("dapui")
			local cortex = require("dap-cortex-debug")

			-- Setup dap-ui
			dapui.setup()

			-- Configure the adapter. Ensure the extension_path points to the cortex-debug install.
			cortex.setup({
				debug = false, -- enable debug logs?
				extension_path = nil, -- default: auto-detect via mason or VSCode extensions
				node_path = "node", -- path to Node.js
				dap_vscode_filetypes = { "c", "cpp" }, -- filetypes for "Launch" commands
				dapui_rtt = true, -- integrate RTT output in dap-ui
				-- ... you can set other options here (refer to plugin README)
			})

			-- Define a DAP configuration for C using OpenOCD + ST-LINK (example).
			-- !!! Configured for one Project!!!
			-- This needs to be adjusted for other projects
			dap.configurations.c = {
				cortex.openocd_config({
					name = "Debug STM32 with OpenOCD",
					cwd = "${workspaceFolder}",
					executable = "FirstProject/Debug/FirstProject.elf", -- change to correct elf_path
					configFiles = { "${workspaceFolder}/FirstProject/openocd/connect.cfg" },
					gdbTarget = "localhost:3333",
					rttConfig = cortex.rtt_config(0), -- use RTT channel 0 for console
					showDevDebugOutput = true,
					toolchainPath = "/opt/homebrew/bin", -- change this to your toolchain path
				}),
			}

			-- -- C++ Adapter Setup:
			-- dap.adapters.gdb = {
			-- 	type = "executable",
			-- 	command = "gdb",
			-- 	args = { "--interpreter=dap", "--eval-command", "set print pretty on" },
			-- }

			-- -- C++ Adapter Config:
			-- dap.configurations.cpp = {
			-- 	{
			-- 		name = "Launch via GDB",
			-- 		type = "gdb",
			-- 		request = "launch",
			-- 		program = function()
			-- 			return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
			-- 		end,
			-- 		cwd = "${workspaceFolder}",
			-- 		stopOnEntry = true,
			-- 		args = {}, -- Add CLI args if needed
			-- 	},
			-- }

			-- -- Rust Adapter Config: (using the Cpp Adapter Setup)
			-- dap.configurations.cpp = {
			-- 	{
			-- 		name = "Launch via GDB",
			-- 		type = "gdb",
			-- 		request = "launch",
			-- 		program = function()
			-- 			return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
			-- 		end,
			-- 		cwd = "${workspaceFolder}",
			-- 		stopOnEntry = true,
			-- 		args = {}, -- Add CLI args if needed
			-- 	},
			-- }

			-- -- Embedded C Adapter Setup:
			-- dap.adapters.gdbserver = {
			-- 	type = "server",
			-- 	port = 3333,
			-- 	executable = {
			-- 		command = "gdb-multiarch", -- or just gdb for native targets
			-- 		args = {},
			-- 	},
			-- }

			-- -- Embedded C Adapter Config:
			-- dap.configurations.c = {
			-- 	{
			-- 		name = "Attach to gdbserver",
			-- 		type = "gdbserver",
			-- 		request = "launch",
			-- 		program = function()
			-- 			return vim.fn.input("Path to ELF: ", vim.fn.getcwd() .. "/", "file")
			-- 		end,
			-- 		cwd = "${workspaceFolder}",
			-- 		miMode = "gdb",
			-- 		miDebuggerServerAddress = "localhost:3333",
			-- 		miDebuggerPath = "/usr/bin/arm-none-eabi-gdb", -- Change to your GDB binary
			-- 		stopOnEntry = true,
			-- 	},
			-- }

			-- Lua Adapter Setup:
			dap.adapters.nlua = function(callback, config)
				callback({ type = "server", host = config.host or "127.0.0.1", port = config.port or 8086 })
			end
			-- Lua Adapter Config:
			dap.configurations["lua"] = {
				{
					type = "nlua",
					request = "attach",
					name = "Attach to running Neovim instance",
				},
			}

			-- Bash Adapter Setup:
			dap.adapters.bash = {
				type = "executable",
				command = vim.fn.expand("~/.local/share/nvim/mason/packages/bash-debug-adapter/bash-debug-adapter"),
				args = {},
			}
			-- Bash Adapter Config:
			dap.configurations.bash = {
				{
					name = "Launch Bash Script",
					type = "bash",
					request = "launch",
					program = function()
						return vim.fn.input("Path to script: ", vim.fn.getcwd() .. "/", "file")
					end,
					cwd = "${workspaceFolder}",
					terminalKind = "integrated",
				},
			}

			-- Keybindings
			local keymap = vim.keymap.set
            -- stylua: ignore start
			keymap("n", "<leader>dc", ":DapContinue<CR>", { desc = "Debugger continue", noremap = true, silent = true })
			keymap("n", "<leader>dd", ":DapNew<CR>", { desc = "Debugger new session", noremap = true, silent = true })
			keymap("n", "<leader>db", ":DapToggleBreakpoint<CR>", { desc = "Debugger toggle breakpoint", noremap = true, silent = true })
			keymap("n", "<leader>dn", ":DapStepOver<CR>", { desc = "Step Over", noremap = true, silent = true })
			keymap("n", "<leader>di", ":DapStepInto<CR>", { desc = "Step Into", noremap = true, silent = true })
			keymap("n", "<leader>do", ":DapStepOut<CR>", { desc = "Step Out", noremap = true, silent = true })
			keymap("n", "<leader>dq", ":DapTerminate<CR>", { desc = "Stop Debugging", noremap = true, silent = true })
			-- stylua: ignore end

			keymap("n", "<leader>da", function()
				require("dap").continue()
			end, { desc = "Dap attach", noremap = true })

			keymap("n", "<leader>du", function()
				dapui.toggle({})
			end, { desc = "Dapui Toggle", noremap = true, silent = true })

			keymap("n", "<leader>dw", function()
				local widgets = require("dap.ui.widgets").widgets.hover()
				widgets.hover()
			end, { desc = "Show hover information in a floating window" })

			keymap("n", "<leader>df", function()
				local widgets = require("dap.ui.widgets")
				widgets.centered_float(widgets.frames)
			end, { desc = "Show call stack in a centered floating window" })

			-- Setup dapui_config
			dap.listeners.before.attach.dapui_config = function()
				dapui.open()
			end
			dap.listeners.before.launch.dapui_config = function()
				dapui.open()
			end

			dap.listeners.before.event_terminated.dapui_config = function()
				-- add a 1sec delay before closing the debugger
				dapui.close()
			end

			dap.listeners.before.event_exited.dapui_config = function()
				dapui.close()
			end
		end,
	},

	-- This is required to configure debuggers with mason-nvim-dap
	-- load this after all adapters have been setup
	{
		"jay-babu/mason-nvim-dap.nvim",
		event = "VeryLazy",
		dependencies = { "williamboman/mason.nvim", "mfussenegger/nvim-dap" },
		opts = {

			handlers = {},
			ensure_installed = {
				"osv",
			},
		},
	},
}

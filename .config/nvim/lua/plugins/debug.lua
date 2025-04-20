return {
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"rcarriga/nvim-dap-ui",
			"theHamsta/nvim-dap-virtual-text",
			"jay-babu/mason-nvim-dap.nvim",
			"williamboman/mason.nvim",
			"nvim-neotest/nvim-nio",
			"jbyuki/one-small-step-for-vimkind",
		},

		config = function()
			local dap = require("dap")
			local dapui = require("dapui")
			local v_text = require("nvim-dap-virtual-text")

			-- Setup dap-ui
			dapui.setup()
			v_text.setup()

			-- C++ Adapter Setup:
			dap.adapters.gdb = {
				type = "executable",
				command = "gdb",
				args = { "--interpreter=dap", "--eval-command", "set print pretty on" },
			}
			-- C++ Adapter Config:
			dap.configurations.cpp = {
				{
					name = "Launch via GDB",
					type = "gdb",
					request = "launch",
					program = function()
						return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
					end,
					cwd = "${workspaceFolder}",
					stopOnEntry = true,
					args = {}, -- Add CLI args if needed
				},
			}
			-- Rust Adapter Config: (using the Cpp Adapter Setup)
			dap.configurations.cpp = {
				{
					name = "Launch via GDB",
					type = "gdb",
					request = "launch",
					program = function()
						return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
					end,
					cwd = "${workspaceFolder}",
					stopOnEntry = true,
					args = {}, -- Add CLI args if needed
				},
			}

			-- Embedded C Adapter Setup:
			dap.adapters.gdbserver = {
				type = "server",
				port = 3333,
				executable = {
					command = "gdb-multiarch", -- or just gdb for native targets
					args = {},
				},
			}
			-- Embedded C Adapter Config:
			dap.configurations.c = {
				{
					name = "Attach to gdbserver",
					type = "gdbserver",
					request = "launch",
					program = function()
						return vim.fn.input("Path to ELF: ", vim.fn.getcwd() .. "/", "file")
					end,
					cwd = "${workspaceFolder}",
					miMode = "gdb",
					miDebuggerServerAddress = "localhost:3333",
					miDebuggerPath = "/usr/bin/arm-none-eabi-gdb", -- Change to your GDB binary
					stopOnEntry = true,
				},
			}

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

			keymap("n", "<leader>dl", function()
				require("osv").launch({ port = 8086 })
			end, { desc = "Launch Lua Debugserver", noremap = true })

			keymap("n", "<leader>dw", function()
				local widgets = require("dap.ui.widgets").widgets.hover()
				widgets.hover()
			end, { desc = "Show hover information in a floating window" })

			keymap("n", "<leader>df", function()
				local widgets = require("dap.ui.widgets")
				widgets.centered_float(widgets.frames)
			end, { desc = "Show call stack in a centered floating window" })

			keymap("n", "<leader>da", function()
				require("dap").continue()
			end, { desc = "DAP Attach to Lua", noremap = true })

			keymap("n", "<leader>du", function()
				require("dapui").toggle({})
			end, { desc = "DapUi Toggle", noremap = true, silent = true })

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

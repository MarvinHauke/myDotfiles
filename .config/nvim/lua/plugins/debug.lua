return {
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"rcarriga/nvim-dap-ui",
			"theHamsta/nvim-dap-virtual-text",
			"jay-babu/mason-nvim-dap.nvim",
			"williamboman/mason.nvim",
		},
		config = function()
			local dap = require("dap")
			local dapui = require("dapui")

			-- Setup dap-ui
			dapui.setup()
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

			-- Setup debug Adapters:
			-- C, C++ and Rust: (https://github.com/mfussenegger/nvim-dap/wiki/C-C---Rust-(via--codelldb))
			dap.adapters.codelldb = {
				type = "executable",
				command = "codelldb",
			}

			-- C Config
			dap.configurations.c = {
				{
					name = "Launch file",
					type = "codelldb",
					request = "launch",
					program = function()
						return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
					end,
					cwd = "${workspaceFolder}",
					stopOnEntry = true,
				},
			}

			-- C++ Config
			dap.configurations.cpp = {
				{
					name = "Launch C++ Program",
					type = "codelldb",
					request = "launch",
					program = function()
						return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
					end,
					cwd = "${workspaceFolder}",
					stopOnEntry = true,
					args = {}, -- You can add CLI arguments here
				},
			}

			-- Rust Config
			dap.configurations.rust = {
				{
					name = "Launch Rust Program",
					type = "codelldb",
					request = "launch",
					program = function()
						-- Auto-detects Rust binary using Cargo
						return vim.fn.getcwd() .. "/target/debug/" .. vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
					end,
					cwd = "${workspaceFolder}",
					stopOnEntry = true,
					args = {}, -- CLI arguments for Rust binary
				},
			}

			-- Keybindings
			local keymap = vim.keymap.set
			local opts = { noremap = true, silent = true }
			keymap("n", "<leader>dc", ":DapContinue<CR>", vim.tbl_extend("keep", { desc = "Debugger continue" }, opts))
			keymap(
				"n",
				"<leader>db",
				":DapToggleBreakpoint<CR>",
				vim.tbl_extend("keep", { desc = "Debugger toggle breakpoint" }, opts)
			)
		end,
	},

	-- This is required to configure debuggers with mason-nvim-dap
	{
		"jay-babu/mason-nvim-dap.nvim",
		event = "VeryLazy",
		dependencies = { "williamboman/mason.nvim", "mfussenegger/nvim-dap" },
		opts = {
			handlers = {},
			ensure_installed = {
				"codelldb",
			},
		},
	},
}

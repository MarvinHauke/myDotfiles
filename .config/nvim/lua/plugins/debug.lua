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
			dap.adapters.codelldb = {
				type = "executable",
				command = "codelldb",
			}

			dap.adapters.bash = {
				type = "executable",
				command = vim.fn.expand("~/.local/share/nvim/mason/packages/bash-debug-adapter/bash-debug-adapter"),
				args = {},
			}

			-- Bash config
			dap.configurations.sh = {
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

			-- Use overseer for running preLaunchTask and postDebugTask.
			-- require("overseer").patch_dap(true)
			-- require("dap.ext.vscode").json_decode = require("overseer.json").decode

			-- Lua Config

			dap.adapters.nlua = function(callback, config)
				callback({ type = "server", host = config.host or "127.0.0.1", port = config.port or 8086 })
			end

			dap.configurations["lua"] = {
				{
					type = "nlua",
					request = "attach",
					name = "Attach to running Neovim instance",
				},
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
			keymap("n", "<leader>dd", ":DapNew<CR>", vim.tbl_extend("keep", { desc = "Debugger new session" }, opts))
			keymap(
				"n",
				"<leader>db",
				":DapToggleBreakpoint<CR>",
				vim.tbl_extend("keep", { desc = "Debugger toggle breakpoint" }, opts)
			)
			keymap("n", "<leader>dn", ":DapStepOver<CR>", vim.tbl_extend("keep", { desc = "Step Over" }, opts))
			keymap("n", "<leader>di", ":DapStepInto<CR>", { desc = "Step Into" }, opts)
			keymap("n", "<leader>do", ":DapStepOut<CR>", { desc = "Step Out" })
			keymap("n", "<leader>dq", ":DapTerminate<CR>", { desc = "Stop Debugging" }, opts)
			keymap("n", "<leader>dl", function()
				require("osv").launch({ port = 8086 })
			end, { desc = "launch Lua Debugserver" }, opts)
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
				"codelldb",
				"osv",
			},
		},
	},
}

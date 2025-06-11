return {
	"Vigemus/iron.nvim",

	config = function()
		local iron = require("iron.core")
		local view = require("iron.view")
		local common = require("iron.fts.common")

		iron.setup({
			config = {
				-- Whether a repl should be discarded or not
				scratch_repl = true,
				-- Your repl definitions come here
				repl_definition = {
					sh = {
						-- Can be a table or a function that
						-- returns a table (see below)
						command = { "zsh" },
					},
					python = {
						command = { "ipython", "--no-autoindent" },
						-- command = { "python3" }, for normal python interpreter
						format = common.bracketed_paste_python,
						block_dividers = { "# %%", "#%%" },
					},
					lua = {
						command = { "lua" },
						block_dividers = { "-- %%", "--%%" },
					},
				},
				-- set the file type of the newly created repl to ft
				-- bufnr is the buffer id of the REPL and ft is the filetype of the
				-- language being used for the REPL.
				repl_filetype = function(bufnr, ft)
					return ft
					-- or return a string name such as the following
					-- return "iron"
				end,
				-- How the repl window will be displayed
				-- See below for more information
				-- repl_open_cmd = view.right(80), <-- this is the normal split variant
				-- repl_open_cmd = "vertical split",

				-- repl_open_cmd can also be an array-style table so that multiple
				-- repl_open_commands can be given.
				-- When repl_open_cmd is given as a table, the first command given will
				-- be the command that `IronRepl` initially toggles.
				-- Moreover, when repl_open_cmd is a table, each key will automatically
				-- be available as a keymap (see `keymaps` below) with the names
				-- toggle_repl_with_cmd_1, ..., toggle_repl_with_cmd_k
				-- For example,
				--
				repl_open_cmd = {
					view.split.vertical.rightbelow("%40"), -- cmd_1: open a repl to the right
					view.split.rightbelow("%25"), -- cmd_2: open a repl below
				},
			},
			-- Iron doesn't set keymaps by default anymore.
			-- You can set them here or manually add keymaps to the functions in iron.core
			keymaps = {
				toggle_repl = "<space>Rr", -- Toggle REPL
				-- If repl_open_command is a table as above, then the following keymaps are
				-- available
				-- toggle_repl_with_cmd_1 = "<space>rv",
				-- toggle_repl_with_cmd_2 = "<space>rh",
				restart_repl = "<space>RR", -- Restart REPL
				send_motion = "<space>em", -- execute motion
				visual_send = "<space>ev", -- execute visual selection
				send_file = "<space>ef", -- execute file
				send_line = "<space>el", --  desc = execute current line
				send_paragraph = "<space>ep", -- execute paragraph
				-- send_until_cursor = "<space>su",
				-- send_mark = "<space>sm",
				send_code_block = "<space>eb", -- execute code block
				send_code_block_and_move = "<space>en", -- send code block and move cursor
				-- mark_motion = "<space>mc",
				-- mark_visual = "<space>mc",
				-- remove_mark = "<space>md",
				cr = "<space>s<cr>", -- send Carriage Return line
				interrupt = "<space>s<space>", -- send space
				exit = "<space>rq", -- exit REPL
				clear = "<space>rl", -- clear REPL
			},
			-- If the highlight is on, you can change how it looks
			-- For the available options, check nvim_set_hl
			highlight = {
				italic = true,
			},
			ignore_blank_lines = true, -- ignore blank lines when sending visual select lines
		})

		-- iron also has a list of commands, see :h iron-commands for all available commands
		vim.keymap.set("n", "<space>rf", "<cmd>IronFocus<cr>")
		vim.keymap.set("n", "<space>rh", "<cmd>IronHide<cr>")
	end,
}
-- {
-- 	{
-- 		"kiyoon/jupynium.nvim",
-- 		-- build = "pip3 install --user .",
-- 		build = "uv pip install . --python=$HOME/.virtualenvs/jupynium/bin/python",
-- 		-- build = "conda run --no-capture-output -n jupynium pip install .",
-- 	},
--
-- 	"rcarriga/nvim-notify", -- optional
-- 	"stevearc/dressing.nvim", -- optional, UI for :JupyniumKernelSelect
-- },

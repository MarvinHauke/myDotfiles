return {
	-- Git commands integration
	{
		"tpope/vim-fugitive",
		cmd = { "Git", "G", "Gdiffsplit", "Gread", "Gwrite", "Ggrep", "GMove", "GDelete", "GBrowse" },
		keys = {
			{ "<leader>gs", "<cmd>Git<cr>", desc = "Git status" },
			{ "<leader>gc", "<cmd>Git commit<cr>", desc = "Git commit" },
			{ "<leader>gd", "<cmd>Gdiffsplit<cr>", desc = "Git diff" },
			{ "<leader>gb", "<cmd>Git blame<cr>", desc = "Git blame" },
		},
	},

	{
		"lewis6991/gitsigns.nvim",
		dependencies = { "dotfiles.nvim" }, -- Ensure dotfiles loads first
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			local has_dotfiles, dotfiles = pcall(require, "dotfiles")

			local config = {
				signs = {
					add = { text = "│" },
					change = { text = "│" },
					delete = { text = "_" },
					topdelete = { text = "‾" },
					changedelete = { text = "~" },
					untracked = { text = "┆" },
				},
				signcolumn = true,
				numhl = false,
				linehl = false,
				word_diff = false,
				watch_gitdir = {
					follow_files = true,
				},
				auto_attach = true,
				attach_to_untracked = true,
				current_line_blame = false,
				current_line_blame_opts = {
					virt_text = true,
					virt_text_pos = "eol",
					delay = 1000,
					ignore_whitespace = false,
					virt_text_priority = 100,
				},
				current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
				sign_priority = 6,
				update_debounce = 100,
				status_formatter = nil,
				max_file_length = 40000,
				preview_config = {
					border = "single",
					style = "minimal",
					relative = "cursor",
					row = 0,
					col = 1,
				},
				on_attach = function(bufnr)
					local gs = package.loaded.gitsigns
					local function map(mode, l, r, opts)
						opts = opts or {}
						opts.buffer = bufnr
						vim.keymap.set(mode, l, r, opts)
					end

					-- Navigation
					map("n", "]c", function()
						if vim.wo.diff then
							return "]c"
						end
						vim.schedule(function()
							gs.next_hunk()
						end)
						return "<Ignore>"
					end, { expr = true, desc = "Next hunk" })

					map("n", "[c", function()
						if vim.wo.diff then
							return "[c"
						end
						vim.schedule(function()
							gs.prev_hunk()
						end)
						return "<Ignore>"
					end, { expr = true, desc = "Previous hunk" })

					-- Actions
					map("n", "<leader>hs", gs.stage_hunk, { desc = "Stage hunk" })
					map("n", "<leader>hr", gs.reset_hunk, { desc = "Reset hunk" })
					map("v", "<leader>hs", function()
						gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
					end, { desc = "Stage hunk" })
					map("v", "<leader>hr", function()
						gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
					end, { desc = "Reset hunk" })
					map("n", "<leader>hS", gs.stage_buffer, { desc = "Stage buffer" })
					map("n", "<leader>hu", gs.undo_stage_hunk, { desc = "Undo stage hunk" })
					map("n", "<leader>hR", gs.reset_buffer, { desc = "Reset buffer" })
					map("n", "<leader>hp", gs.preview_hunk, { desc = "Preview hunk" })
					map("n", "<leader>hb", function()
						gs.blame_line({ full = true })
					end, { desc = "Blame line" })
					map("n", "<leader>tb", gs.toggle_current_line_blame, { desc = "Toggle line blame" })
					map("n", "<leader>hd", gs.diffthis, { desc = "Diff this" })
					map("n", "<leader>hD", function()
						gs.diffthis("~")
					end, { desc = "Diff this ~" })
					map("n", "<leader>td", gs.toggle_deleted, { desc = "Toggle deleted" })

					-- Text object
					map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", { desc = "Select hunk" })
				end,
			}

			-- Add dotfiles worktree
			if has_dotfiles and dotfiles.get_home_dir and dotfiles.get_dotfiles_dir then
				config.worktrees = {
					{
						toplevel = dotfiles.get_home_dir(),
						gitdir = dotfiles.get_dotfiles_dir(),
					},
				}
			else
				-- Fallback to hardcoded dotfiles setup
				local home = vim.env.HOME
				local dotfiles_dir = home .. "/.cfg"
				if vim.fn.isdirectory(dotfiles_dir) == 1 then
					config.worktrees = {
						{
							toplevel = home,
							gitdir = dotfiles_dir,
						},
					}
				end
			end

			require("gitsigns").setup(config)
		end,
	},
	-- Enhanced git blame
	{
		"f-person/git-blame.nvim",
		dependencies = { "dotfiles.nvim" },
		event = "VeryLazy",
		enabled = true,
		config = function()
			-- Check if dotfiles plugin is available
			local has_dotfiles, dotfiles = pcall(require, "dotfiles")
			local config = {
				enabled = false, -- disabled by default
				date_format = "%m/%d/%y %H:%M:%S",
				message_template = " <summary> • <date> • <author>",
				message_when_not_committed = " Not Committed Yet",
				highlight_group = "Comment",
				set_extmark_options = {
					priority = 7,
				},
			}
			-- Add git command function if dotfiles plugin is available
			if has_dotfiles then
				config.git_command = function()
					return dotfiles.get_git_cmd_string()
				end
			else
				-- Fallback git command detection
				config.git_command = function()
					local current_file = vim.fn.expand("%:p")
					local home = vim.env.HOME
					local dotfiles_dir = home .. "/.cfg"
					if vim.startswith(current_file, home) and vim.fn.isdirectory(dotfiles_dir) == 1 then
						-- Simple check if file might be a dotfile (you can enhance this)
						return "git --git-dir=" .. dotfiles_dir .. " --work-tree=" .. home
					end
					return "git"
				end
			end
			require("gitblame").setup(config)
		end,
		keys = {
			{ "<leader>gb", "<cmd>GitBlameToggle<cr>", desc = "Toggle git blame" },
			{ "<leader>gB", "<cmd>GitBlameOpenCommitURL<cr>", desc = "Open commit URL" },
		},
	},

	-- Additional git utilities
	{
		"sindrets/diffview.nvim",
		dependencies = { "dotfiles.nvim" },
		cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles" },
		config = function()
			-- Check if dotfiles plugin is available
			local has_dotfiles, dotfiles = pcall(require, "dotfiles")
			local config = {
				diff_binaries = false,
				enhanced_diff_hl = false,
			}
			-- Add git command function if dotfiles plugin is available
			if has_dotfiles then
				config.git_cmd = function()
					return dotfiles.get_git_cmd()
				end
			else
				-- Fallback git command detection
				config.git_cmd = function()
					local current_file = vim.fn.expand("%:p")
					local home = vim.env.HOME
					local dotfiles_dir = home .. "/.cfg"
					if vim.startswith(current_file, home) and vim.fn.isdirectory(dotfiles_dir) == 1 then
						return { "git", "--git-dir=" .. dotfiles_dir, "--work-tree=" .. home }
					end
					return { "git" }
				end
			end
			require("diffview").setup(config)
		end,
		keys = {
			{ "<leader>gv", "<cmd>DiffviewOpen<cr>", desc = "Open diffview" },
			{ "<leader>gV", "<cmd>DiffviewClose<cr>", desc = "Close diffview" },
		},
	},

	-- Git conflict resolution
	{
		"akinsho/git-conflict.nvim",
		event = "BufReadPre",
		opts = {
			default_mappings = true,
			default_commands = true,
			disable_diagnostics = false,
			list_opener = "copen",
			highlights = {
				incoming = "DiffAdd",
				current = "DiffText",
			},
		},
		keys = {
			{ "<leader>co", "<cmd>GitConflictChooseOurs<cr>", desc = "Choose ours" },
			{ "<leader>ct", "<cmd>GitConflictChooseTheirs<cr>", desc = "Choose theirs" },
			{ "<leader>cb", "<cmd>GitConflictChooseBoth<cr>", desc = "Choose both" },
			{ "<leader>c0", "<cmd>GitConflictChooseNone<cr>", desc = "Choose none" },
			{ "[x", "<cmd>GitConflictPrevConflict<cr>", desc = "Previous conflict" },
			{ "]x", "<cmd>GitConflictNextConflict<cr>", desc = "Next conflict" },
		},
	},
}

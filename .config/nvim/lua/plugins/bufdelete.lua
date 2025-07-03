return {
	"famiu/bufdelete.nvim",
	config = function()
		-- Cache commonly used API functions for better performance
		local api = vim.api
		local bo = vim.bo
		local fn = vim.fn
		local cmd = vim.cmd

		-- Configuration table for special buffer types
		local SPECIAL_FILETYPES = {
			"NvimTree",
			"neo-tree",
			"oil",
			"help",
			"qf",
			"trouble",
			"terminal",
			"fugitive",
			"git",
			"gitcommit",
			"alpha",
			"startify",
			"dashboard",
			"lspinfo",
			"mason",
			"lazy",
			"toggleterm",
		}

		-- Convert to set for O(1) lookup
		local special_ft_set = {}
		for _, ft in ipairs(SPECIAL_FILETYPES) do
			special_ft_set[ft] = true
		end

		-- Get all listed buffers
		local function get_listed_buffers()
			return vim.tbl_filter(function(buf)
				return api.nvim_buf_is_valid(buf) and bo[buf].buflisted
			end, api.nvim_list_bufs())
		end

		-- Check if buffer is empty
		local function is_buffer_empty(buf)
			if not api.nvim_buf_is_valid(buf) then
				return true
			end
			local lines = api.nvim_buf_get_lines(buf, 0, -1, false)
			return #lines == 1 and lines[1] == ""
		end

		-- Check if only special buffers are open
		local function is_only_special_buffers_open()
			local wins = api.nvim_tabpage_list_wins(0)
			local non_special_count = 0
			local current_buf = api.nvim_get_current_buf()

			for _, win in ipairs(wins) do
				local buf = api.nvim_win_get_buf(win)
				local ft = bo[buf].filetype
				-- Count non-special buffers, but exclude the current buffer we're about to close
				if not special_ft_set[ft] and buf ~= current_buf then
					non_special_count = non_special_count + 1
				end
			end

			-- If no non-special buffers remain (after excluding current), quit
			return non_special_count == 0
		end

		-- Handle unsaved buffer - set nomodified to avoid double prompts
		local function handle_unsaved_buffer(buf)
			local buf_name = api.nvim_buf_get_name(buf)
			local display_name = buf_name ~= "" and fn.fnamemodify(buf_name, ":t") or "[No Name]"

			local choice = fn.confirm(string.format('Save changes to "%s"?', display_name), "&Yes\n&No\n&Cancel", 1)

			if choice == 1 then -- Yes (Save)
				if buf_name == "" then
					-- Prompt for filename for unnamed buffer
					local save_path = fn.input("Save as: ", fn.getcwd() .. "/", "file")
					if save_path and save_path ~= "" then
						local ok, err = pcall(cmd, "write! " .. fn.fnameescape(save_path))
						if not ok then
							vim.notify("Error saving file: " .. err, vim.log.levels.ERROR)
							return false
						end
						return true
					else
						return false -- User cancelled save dialog
					end
				else
					local ok, err = pcall(cmd, "write!")
					if not ok then
						vim.notify("Error saving file: " .. err, vim.log.levels.ERROR)
						return false
					end
					return true
				end
			elseif choice == 2 then -- No (Don't save)
				-- Set buffer as unmodified to prevent Neovim's built-in prompt
				bo[buf].modified = false
				return true
			else -- Cancel
				return false
			end
		end

		-- Main quit function with better logic separation
		local function smart_quit(force)
			local listed_buffers = get_listed_buffers()
			local current_buf = api.nvim_get_current_buf()

			-- Handle multiple buffers
			if #listed_buffers > 1 then
				if not force and bo[current_buf].modified then
					if not handle_unsaved_buffer(current_buf) then
						return -- User cancelled
					end
				end

				-- Check if after deleting this buffer, only special buffers would remain
				if is_only_special_buffers_open() then
					cmd(force and "quit!" or "quit")
					return
				end

				local delete_cmd = force and "Bwipeout!" or "Bdelete"
				local ok, err = pcall(cmd, delete_cmd)
				if not ok then
					vim.notify("Error deleting buffer: " .. err, vim.log.levels.ERROR)
				end
				return
			end

			-- Handle single buffer case
			local last_buf = listed_buffers[1]
			if not last_buf then
				cmd(force and "quit!" or "quit") -- No valid buffers, just quit
				return
			end

			local buf_name = api.nvim_buf_get_name(last_buf)
			local is_modified = bo[last_buf].modified

			-- Handle unsaved changes
			if not force and is_modified then
				if not handle_unsaved_buffer(last_buf) then
					return -- User cancelled
				end
			end

			-- For single buffer, always check if only special buffers remain
			if is_only_special_buffers_open() then
				cmd(force and "quit!" or "quit")
				return
			end

			-- For unnamed empty buffers, quit Vim entirely
			if buf_name == "" and is_buffer_empty(last_buf) then
				cmd(force and "quit!" or "quit")
			else
				-- Try to delete buffer, fallback to quit if it fails
				local delete_cmd = force and "Bwipeout!" or "Bdelete"
				local ok = pcall(cmd, delete_cmd)
				if not ok then
					cmd(force and "quit!" or "quit")
				end
			end
		end

		-- Create user commands
		api.nvim_create_user_command("Q", function(opts)
			smart_quit(opts.bang)
		end, {
			desc = "Smart buffer delete or quit",
			bang = true, -- Allow ! modifier
		})

		api.nvim_create_user_command("QForce", function()
			smart_quit(true)
		end, { desc = "Force buffer wipeout or quit" })

		-- Set up command aliases
		cmd("cabbrev q Q")
		-- Don't create q! abbreviation - let Q handle it with bang
	end,
}

return {
	"famiu/bufdelete.nvim",
	config = function()
		local function get_listed_buffers()
			return vim.tbl_filter(function(buf)
				return vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted
			end, vim.api.nvim_list_bufs())
		end

		local function is_buffer_empty(buf)
			if not vim.api.nvim_buf_is_valid(buf) then
				return true
			end
			local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
			return #lines == 1 and lines[1] == ""
		end

		local function is_only_special_buffers_open()
			local wins = vim.api.nvim_tabpage_list_wins(0)
			for _, win in ipairs(wins) do
				local buf = vim.api.nvim_win_get_buf(win)
				local ft = vim.bo[buf].filetype
				-- Check for common special buffer types
				if
					ft ~= "NvimTree"
					and ft ~= "neo-tree"
					and ft ~= "oil"
					and ft ~= "help"
					and ft ~= "qf"
					and ft ~= "trouble"
				then
					return false
				end
			end
			return true
		end

		local function handle_unsaved_buffer(buf)
			local buf_name = vim.api.nvim_buf_get_name(buf)
			local display_name = buf_name ~= "" and vim.fn.fnamemodify(buf_name, ":t") or "[No Name]"

			local choice =
				vim.fn.confirm(string.format('Save changes to "%s"?', display_name), "&Save\n&Don't Save\n&Cancel", 1)

			if choice == 1 then -- Save
				if buf_name == "" then
					-- Prompt for filename for unnamed buffer
					local save_path = vim.fn.input("Save as: ", vim.fn.getcwd() .. "/", "file")
					if save_path and save_path ~= "" then
						vim.cmd("write! " .. vim.fn.fnameescape(save_path))
						return true
					else
						return false -- User cancelled save dialog
					end
				else
					vim.cmd("write!")
					return true
				end
			elseif choice == 2 then -- Don't save
				return true
			else -- Cancel
				return false
			end
		end

		vim.api.nvim_create_user_command("Q", function()
			local listed_buffers = get_listed_buffers()

			-- If multiple buffers, just delete current one
			if #listed_buffers > 1 then
				-- Check if current buffer has unsaved changes
				local current_buf = vim.api.nvim_get_current_buf()
				if vim.bo[current_buf].modified then
					if not handle_unsaved_buffer(current_buf) then
						return -- User cancelled
					end
				end
				vim.cmd("Bdelete")
				return
			end

			-- Handle single buffer case
			local last_buf = listed_buffers[1]
			if not last_buf then
				vim.cmd("quit") -- No valid buffers, just quit
				return
			end

			local buf_name = vim.api.nvim_buf_get_name(last_buf)
			local is_modified = vim.bo[last_buf].modified

			-- Handle unsaved changes
			if is_modified then
				if not handle_unsaved_buffer(last_buf) then
					return -- User cancelled
				end
			end

			-- Check if only special buffers (file explorers, etc.) are open
			if is_only_special_buffers_open() then
				vim.cmd("quit")
				return
			end

			-- For unnamed empty buffers, quit Vim entirely
			if buf_name == "" and is_buffer_empty(last_buf) then
				vim.cmd("quit")
			else
				-- Try to delete buffer, fallback to quit if it fails
				local ok = pcall(vim.cmd, "Bdelete")
				if not ok then
					vim.cmd("quit")
				end
			end
		end, { desc = "Smart buffer delete or quit" })

		-- Create QForce command for force wipeout
		vim.api.nvim_create_user_command("QForce", function()
			local listed_buffers = get_listed_buffers()
			if #listed_buffers > 1 then
				vim.cmd("Bwipeout!")
			else
				vim.cmd("quit!")
			end
		end, { desc = "Force buffer wipeout or quit" })

		-- Set up command aliases
		vim.cmd("cabbrev q Q")
		vim.cmd("cabbrev q! QForce")
	end,
}

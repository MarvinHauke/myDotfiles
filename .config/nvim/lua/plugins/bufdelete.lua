return {
	"famiu/bufdelete.nvim",
	config = function()
		vim.api.nvim_create_user_command("Q", function()
			local buffers = vim.api.nvim_list_bufs()
			local listed_buffers = vim.tbl_filter(function(buf)
				return vim.api.nvim_buf_get_option(buf, "buflisted")
			end, buffers)

			if #listed_buffers > 1 then
				vim.cmd("Bdelete")
			else
				-- Get the last buffer info
				local last_buf = listed_buffers[1] or buffers[1] -- Use fallback buffer
				local last_buf_name = last_buf and vim.api.nvim_buf_get_name(last_buf) or ""
				local last_buf_modified = vim.api.nvim_buf_get_option(last_buf, "modified")

				-- Check if only nvim-tree is open
				local open_windows = vim.api.nvim_tabpage_list_wins(0)
				local nvim_tree_only = #open_windows == 1
					and vim.bo[vim.api.nvim_win_get_buf(open_windows[1])].filetype == "NvimTree"

				-- Handle unnamed buffers
				if last_buf_name == "" then
					local buf_contents = vim.api.nvim_buf_get_lines(last_buf, 0, -1, false)
					local is_empty = buf_contents == 1 and buf_contents[1] == ""

					if is_empty then
						-- If last buffer is empty, exit Vim completely
						vim.cmd("qa!")
					elseif last_buf_modified then
						-- If modified, ask user to save
						local choice = vim.fn.confirm("Save changes?", "&Yes\n&No\n&Cancel", 3)
						if choice == 1 then
							-- User chose to save, ask for filename
							local save_path = vim.fn.input("Save as: ", vim.fn.getcwd() .. "/", "file")
							if save_path and save_path ~= "" then
								vim.cmd("write! " .. save_path)
								vim.cmd("quit")
							end
						elseif choice == 2 then
							-- User chose not to save, exit Vim
							vim.cmd("qa!")
						end
					else
						-- Just exit if last buffer is unnamed but not modified
						vim.cmd("qa!")
					end
				elseif nvim_tree_only then
					vim.cmd("quit")
				else
					vim.cmd("Bdelete")
				end
			end
		end, {})

		-- Make `q` an alias for `Q`, and `q!` an alias for `Bwipeout`
		vim.cmd("cabbrev Q! Bwipeout")
		vim.cmd("cabbrev q Q")
	end,
}

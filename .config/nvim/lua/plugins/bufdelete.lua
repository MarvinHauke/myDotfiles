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
				-- If only one buffer is left, check its name
				local last_buf = listed_buffers[1] or buffers[1] -- Fallback to any buffer if needed
				local last_buf_name = last_buf and vim.api.nvim_buf_get_name(last_buf) or ""

				-- Get the number of listed buffers and check if nvim-tree is the only one left
				local open_windows = vim.api.nvim_tabpage_list_wins(0)
				local nvim_tree_only = #open_windows == 1
					and vim.bo[vim.api.nvim_win_get_buf(open_windows[1])].filetype == "NvimTree"

				if last_buf_name == "" then -- Empty name means "No Name"
					vim.cmd("quit")
					vim.cmd("quit") -- do a second quit for also leaving nvim-tree
				elseif nvim_tree_only then
					vim.cmd("quit")
				else -- Otherwise, just delete the buffer
					vim.cmd("Bdelete")
				end
			end
		end, {})

		-- Make `q` an alias for `Q`, and `q!` an alias for `Bwipeout`
		vim.cmd("cabbrev Q! Bwipeout")
		vim.cmd("cabbrev q Q")
	end,
}

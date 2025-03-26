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
				local last_buf_name = vim.api.nvim_buf_get_name(listed_buffers[1])
				if last_buf_name == "" then -- Empty name means "No Name"
					vim.cmd("quit")
				else
					vim.cmd("quit")
				end
			end
		end, {})

		vim.cmd("cabbrev q Q")
	end,
}

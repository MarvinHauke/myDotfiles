local M = {}

function M.open_command_with_filepath()
	local path = vim.fn.expand("%:p")
	vim.api.nvim_feedkeys(":" .. path, "n", false)
end

return M

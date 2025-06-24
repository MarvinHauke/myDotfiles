local M = {}

function M.open_command_with_filepath()
	local path = vim.fn.expand("%:p")
	vim.api.nvim_feedkeys(":" .. path, "n", false)
end

-- Printfunction for for debugging tables in lua
P = function(v)
	print(vim.inspect(v))
	return v
end

return M

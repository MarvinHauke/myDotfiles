-- Use spaces, not tabs
vim.opt_local.expandtab = true

-- Set indent width to 8 (as per your stylua config)
vim.opt_local.shiftwidth = 4
vim.opt_local.tabstop = 4
vim.opt_local.softtabstop = 4

-- Optional: smarter indentation
vim.opt_local.smartindent = true
vim.opt_local.autoindent = true

-- Disable auto-comment on new line
vim.api.nvim_create_autocmd("BufEnter", {
	pattern = "*",
	callback = function()
		-- Remove 'o' from formatoptions
		vim.opt.formatoptions:remove("o")
	end,
})

-- keymaps for Luafiles
local keymap = vim.keymap.set

-- start Debugserver
keymap("n", "<leader>dl", function()
	require("osv").launch({ port = 8086 })
end, { desc = "Launch Lua Debugserver", noremap = true })

-- Module reloading for plugin development
vim.api.nvim_create_autocmd("BufWritePost", {
	group = group_id,
	pattern = "*.lua",
	callback = function()
		local first_line = vim.api.nvim_buf_get_lines(0, 0, 1, false)[1]
		--only reload if the first line is local M ={}
		if first_line and first_line:match("^local%s+M%s*=%s*{}") then
			local file_path = vim.fn.expand("%:p")
			local module_name = vim.fn.fnamemodify(file_path, ":.:r")

			package.loaded[module_name] = nil
			vim.notify("Module Reloaded: " .. module_name, nil, {
				title = "Notification",
				timeout = 500,
				render = "compact",
			})
		end
	end,
	desc = "Reload the current module on save",
})

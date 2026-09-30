local M = {}

function M.open_command_with_filepath()
	local path = vim.fn.expand("%:p")
	vim.api.nvim_feedkeys(":" .. path, "n", false)
end

-- Open a file in a detached zathura window (does not block nvim)
function M.open_zathura(path)
	vim.fn.jobstart({ "zathura", "--fork", path }, { detach = true })
	-- zathura (plain binary, no .app) does not take focus on macOS, so raise it manually.
	-- Retry until its window process exists instead of waiting a fixed time.
	vim.fn.jobstart({
		"sh",
		"-c",
		[[for i in $(seq 1 40); do
			osascript -e 'tell application "System Events" to set frontmost of first process whose name is "zathura" to true' >/dev/null 2>&1 && exit 0
			sleep 0.05
		done]],
	})
end

-- Open a file in the current window as a hex dump (xxd)
function M.open_hex(path)
	vim.cmd("edit ++bin " .. vim.fn.fnameescape(path))
	vim.cmd("%!xxd")
	vim.bo.filetype = "xxd"
	vim.bo.modified = false
end

-- Open a file in the current window as raw text: bytes are mapped 1:1 (latin1), nothing gets converted
function M.open_raw(path)
	vim.cmd("edit ++bin ++enc=latin1 " .. vim.fn.fnameescape(path))
end

-- Printfunction for for debugging tables in lua
P = function(v)
	print(vim.inspect(v))
	return v
end

return M

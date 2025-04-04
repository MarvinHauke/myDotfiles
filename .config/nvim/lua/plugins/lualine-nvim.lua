return {
	"nvim-lualine/lualine.nvim", -- https://github.com/nvim-lualine/lualine.nvim
	dependencies = {
		"nvim-tree/nvim-web-devicons", -- Fancy icons            https://github.com/nvim-tree/nvim-web-devicons
		"linrongbin16/lsp-progress.nvim", -- LSP loading progress   https://github.com/linrongbin16/lsp-progress.nvim
	},
	opts = {
		options = {
			theme = "dracula", -- lualine theme
			icons_enabled = true,
			component_separators = { left = "", right = "" },
			section_separators = { left = "", right = "" },
		},
		sections = {
			lualine_a = { "mode" },
			lualine_b = { "branch" },
			lualine_c = {
				{
					-- Display LSP clients attached to the buffer with language-specific icons
					function()
						local bufnr = vim.api.nvim_get_current_buf()
						local clients = vim.lsp.get_clients({ bufnr = bufnr })
						if next(clients) == nil then
							return ""
						end

						-- Get filetype of the current buffer
						local filetype = vim.bo.filetype
						local devicons = require("nvim-web-devicons")
						local icon, color = devicons.get_icon_color_by_filetype(filetype)

						local c = {}
						for _, client in pairs(clients) do
							-- Use the fetched icon if available; otherwise, fallback to a gear icon
							local display_icon = icon or ""
							table.insert(c, display_icon .. " " .. client.name)
						end

						return table.concat(c, " | ")
					end,
					color = function()
						local filetype = vim.bo.filetype
						local _, color = require("nvim-web-devicons").get_icon_color_by_filetype(filetype)
						return { fg = color or "#98c379", gui = "bold" }
					end,
				},
				{
					-- Customize the filename part of lualine to be parent/filename
					"filename",
					file_status = true, -- Displays file status (readonly status, modified status)
					newfile_status = false, -- Display new file status
					path = 4, -- 4: Filename and parent dir, with tilde as the home directory
					symbols = {
						modified = "[+]", -- Text to show when the file is modified.
						readonly = "[-]", -- Text to show when the file is readonly.
					},
				},
			},
			lualine_x = { "encoding", "fileformat", "filetype" },
			lualine_y = { "progress" },
			lualine_z = { "location" },
		},
	},
}

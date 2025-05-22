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
				"diagnostics",
				{
					-- TODO: use lsp progress
					-- Display LSP clients attached to the buffer
					function()
						local icon, _ =
							require("nvim-web-devicons").get_icon_by_filetype(vim.bo.filetype, { default = true })
						local clients = vim.lsp.get_clients({ bufnr = vim.api.nvim_get_current_buf() })

						if not clients or vim.tbl_isempty(clients) then
							return icon or ""
						end

						local names = {}
						for _, client in ipairs(clients) do
							table.insert(names, client.name)
						end

						return string.format("%s %s", icon or "", table.concat(names, " | "))
					end,
					color = function()
						local _, color =
							require("nvim-web-devicons").get_icon_color_by_filetype(vim.bo.filetype, { default = true })
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

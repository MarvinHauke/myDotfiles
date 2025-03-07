return {
	"akinsho/bufferline.nvim",
	version = "*",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
		"ojroques/nvim-bufdel", --for deleting buffers without changing the layout
	},
	enabled = true,

	-- Options go here
	opts = {
		options = {
			mode = "buffers",
			offsets = {
				{
					filetype = "NvimTree",
					text = "File Explorer",
					text_align = "left",
					separator = true,
				},
			},
			hover = {
				enabled = true,
				delay = 200,
				reveal = { "close" },
			},
			indicator = {
				style = "underline",
			},
		},
	},
}

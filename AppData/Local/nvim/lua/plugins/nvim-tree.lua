-- File Explorer / Tree
return {
	-- https://github.com/nvim-tree/nvim-tree.lua
	"nvim-tree/nvim-tree.lua",
	dependencies = {
		-- https://github.com/nvim-tree/nvim-web-devicons
		"nvim-tree/nvim-web-devicons", -- Fancy icon support
	},
	opts = {
		actions = {
			open_file = {
				window_picker = {
					enable = true,
				},
			},
		},
	},
	config = function(_, opts)
		require("nvim-tree").setup(opts)
	end,
}

return {
	-- dbee installation:

	"kndndrj/nvim-dbee",
	dependencies = {
		"MunifTanjim/nui.nvim",
	},
	build = function()
		-- Install tries to automatically detect the install method.
		-- if it fails, try calling it with one of these parameters:
		--    "curl", "wget", "bitsadmin", "go"
		require("dbee").install()
	end,
	config = function()
		require("dbee").setup(--[[optional config]])
	end,

	-- dadbod installation:
	-- check if you can do it with dbee dadbod is a bit older
	-- {
	-- 	"tpope/vim-dadbod",
	-- 	"kristijanhusak/vim-dadbod-completion",
	-- 	"kristijanhusak/vim-dadbod-ui",
	-- },
}

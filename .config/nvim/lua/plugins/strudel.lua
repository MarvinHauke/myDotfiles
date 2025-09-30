return {
	"gruvw/strudel.nvim",
	cmd = "StrudelLaunch",
	build = "npm install",
	config = function()
		require("strudel").setup({
			-- ui = {
			-- 	hide_menu_panel = true,
			-- 	hide_top_bar = true,
			-- 	hide_error_display = true,
			-- 	hide_code_editor = true,
			-- 	-- Set `hide_code_editor = false` if you want to overlay the code editor
			-- },
		})
	end,
}

return {
	"hat0uma/csvview.nvim",
	---@module "csvview"
	---@type CsvView.Options
	opts = {
		parser = { comments = { "#", "//" } },
		keymaps = {
			-- Text objects for selecting fields
			textobject_field_inner = { "if", mode = { "o", "x" } },
			textobject_field_outer = { "af", mode = { "o", "x" } },
			-- Excel-like navigation:
			-- Use <Tab> and <S-Tab> to move horizontally between fields.
			-- Use <Enter> and <S-Enter> to move vertically between rows and place the cursor at the end of the field.
			-- Note: In terminals, you may need to enable CSI-u mode to use <S-Tab> and <S-Enter>.
			jump_next_field_end = { "<Tab>", mode = { "n", "v" } },
			jump_prev_field_end = { "<S-Tab>", mode = { "n", "v" } },
			jump_next_row = { "<Enter>", mode = { "n", "v" } },
			jump_prev_row = { "<S-Enter>", mode = { "n", "v" } },
		},
	},
	cmd = { "CsvViewEnable", "CsvViewDisable", "CsvViewToggle" },
	ft = { "csv", "tsv" },
	config = function(_, opts)
		local csvview = require("csvview")
		csvview.setup(opts)
		-- The table view switches on by itself for short files. Long ones stay plain text (:CsvViewToggle).
		local max_lines = 5000
		local function enable(buf)
			local ft = vim.bo[buf].filetype
			if (ft == "csv" or ft == "tsv") and not csvview.is_enabled(buf) and vim.api.nvim_buf_line_count(buf) <= max_lines then
				csvview.enable(buf)
			end
		end
		vim.api.nvim_create_autocmd("FileType", {
			pattern = { "csv", "tsv" },
			callback = function(args)
				enable(args.buf)
			end,
		})
		enable(vim.api.nvim_get_current_buf()) -- the file that loaded the plugin
	end,
}

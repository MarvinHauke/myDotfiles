return {
	-- Setup codeium for auto_suggestions
	{
		"Exafunction/codeium.nvim",
		dpendencies = {
			"nvim-lua/plenary.nvim",
			"hrsh7th/nvim-cmp",
		},
		enabled = true,
		config = function()
			local codeium = require("codeium")
			codeium.setup()
		end,
	},
	-- Set Claude as default provider for avante
	{
		"yetone/avante.nvim",
		event = "VeryLazy",
		version = false, -- Never set this value to "*"! Never!
		opts = {
			provider = "claude",
			providers = {
				claude = {
					endpoint = "https://api.anthropic.com",
					-- Start with cheaper Haiku model
					model = "claude-3-haiku-20240307", -- 12x cheaper than Sonnet!
					timeout = 30000,
					extra_reques_body = {
						temperature = 0, -- More focused responses = fewer tokens
						max_tokens = 2048, -- Reduced from 4096 to save costs
					},
				},
				-- Keep Sonnet as backup for complex tasks
				["claude-sonnet"] = {
					endpoint = "https://api.anthropic.com",
					model = "claude-sonnet-4-20250514", -- Stable version, cheaper than Sonnet 4
					timeout = 30000,
					{
						temperature = 0,
						max_tokens = 4096,
					},
				},
			},
			-- Additional cost-saving settings
			behaviour = {
				auto_suggestions = false, -- Disable to reduce automatic API calls
				-- Automatically set highlight group for generated text
				auto_set_highlight_group = true,
				-- Automatically set keymaps for generated text
				auto_set_keymaps = true,
				-- Disable automatically applying diffs after generation
				auto_apply_diff_after_generation = false,
				-- Enable support for pasting from clipboard
				support_paste_from_clipboard = true,
			},
			-- Custom mappings to switch models on-demand
			mappings = {
				ask = "<leader>aa", -- Use default (Haiku)
				edit = "<leader>ae", -- Use default (Haiku)
				-- Add custom mappings for premium models
				ask_sonnet = "<leader>as", -- Use Sonnet for complex questions
				edit_sonnet = "<leader>es", -- Use Sonnet for complex edits
			},
		},
		-- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
		build = "make",
		-- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			--- The below dependencies are optional,
			-- "echasnovski/mini.pick", -- for file_selector provider mini.pick
			"nvim-telescope/telescope.nvim", -- for file_selector provider telescope
			"hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
			"ibhagwan/fzf-lua", -- for file_selector provider fzf
			"folke/snacks.nvim", -- for input provider snacks
			"nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
			"zbirenbaum/copilot.lua", -- for providers='copilot'
			-- {
			-- 	-- support for image pasting
			-- 	"HakonHarnes/img-clip.nvim",
			-- 	event = "VeryLazy",
			-- 	opts = {
			-- 		-- recommended settings
			-- 		default = {
			-- 			embed_image_as_base64 = false,
			-- 			prompt_for_file_name = false,
			-- 			drag_and_drop = {
			-- 				insert_mode = true,
			-- 			},
			-- 			-- required for Windows users
			-- 			use_absolute_path = true,
			-- 		},
			-- 	},
			-- },
			{
				-- Make sure to set this up properly if you have lazy=true
				"MeanderingProgrammer/render-markdown.nvim",
				opts = {
					file_types = { "markdown", "Avante" },
				},
				ft = { "markdown", "Avante" },
			},
		},
	},
	-- Set up Mcp-server
}

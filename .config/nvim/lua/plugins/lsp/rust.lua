-- Rust LSP Configuration
local lspconfig = require("lspconfig")
local util = require("lspconfig.util")

lspconfig.rust_analyzer.setup({
	capabilities = _G.lsp_common.lsp_capabilities,
	on_attach = _G.lsp_common.lsp_attach,
	filetypes = { "rust" },
	settings = {
		["rust-analyzer"] = {
			checkOnSave = {
				command = "clippy",
			},
			cargo = {
				allFeatures = true,
				rundBuildScripts = true,
			},
			procMacro = {
				enable = true,
			},
		},
	},
	root_dir = function(fname)
		return util.root_pattern("Cargo.toml", "rust-project.json")(fname) or vim.fn.getcwd()
	end,
})

-- Rust LSP Configuration
vim.lsp.config("rust_analyzer", {
	capabilities = _G.lsp_common.lsp_capabilities,
	on_attach = _G.lsp_common.lsp_attach,
	filetypes = { "rust" },
	settings = {
		["rust-analyzer"] = {
			checkOnSave = true,
			check = {
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
	root_dir = vim.fs.root(0, { "Cargo.toml", "rust-project.json" }),
})

vim.lsp.enable("rust_analyzer")

-- C/C++ LSP Configuration
local lspconfig = require("lspconfig")
local util = require("lspconfig.util")

lspconfig.clangd.setup({
	on_attach = _G.lsp_common.lsp_attach,
	capabilities = _G.lsp_common.lsp_capabilities,
	root_dir = util.root_pattern("compile_commands.json", "compile_flags.txt", ".git"),
	cmd = {
		"clangd",
		"--background-index",
		"--clang-tidy",
		"--completion-style=detailed",
		"--pch-storage=memory",
		"--all-scopes-completion",
	},
})

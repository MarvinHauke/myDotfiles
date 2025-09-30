-- C/C++ LSP Configuration
vim.lsp.config("clangd", {
	on_attach = _G.lsp_common.lsp_attach,
	capabilities = _G.lsp_common.lsp_capabilities,
	root_dir = vim.fs.root(0, { "compile_commands.json", "compile_flags.txt", ".git" }),
	cmd = {
		"clangd",
		"--background-index",
		"--clang-tidy",
		"--completion-style=detailed",
		"--pch-storage=memory",
		"--all-scopes-completion",
	},
})

vim.lsp.enable("clangd")

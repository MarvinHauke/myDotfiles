-- CMake LSP Configuration

vim.lsp.config("cmake", {
	capabilities = _G.lsp_common.lsp_capabilities,
	on_attach = _G.lsp_common.lsp_attach,
})

vim.lsp.enable("cmake")

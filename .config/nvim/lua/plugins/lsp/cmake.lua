-- CMake LSP Configuration
local lspconfig = require("lspconfig")

lspconfig.cmake.setup({
	capabilities = _G.lsp_common.lsp_capabilities,
	on_attach = _G.lsp_common.lsp_attach,
})

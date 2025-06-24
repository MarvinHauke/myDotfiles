-- Markup Language LSP Configuration
local lspconfig = require("lspconfig")

-- YAML LSP settings
lspconfig.yamlls.setup({
	capabilities = _G.lsp_common.lsp_capabilities,
	on_attach = _G.lsp_common.lsp_attach,
	settings = {
		yaml = {
			schemaStore = {
				enable = false,
				url = "",
			},
			schemas = require("schemastore").yaml.schemas(),
		},
	},
})

-- Markdown LSP settings
lspconfig.marksman.setup({
	capabilities = _G.lsp_common.lsp_capabilities,
	on_attach = _G.lsp_common.lsp_attach,
})

-- XML LSP settings
lspconfig.lemminx.setup({
	capabilities = _G.lsp_common.lsp_capabilities,
	on_attach = _G.lsp_common.lsp_attach,
})

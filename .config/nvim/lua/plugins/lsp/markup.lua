-- Markup Language LSP Configuration

-- YAML LSP settings
vim.lsp.config("yamlls", {
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

vim.lsp.enable("yamlls")

-- Markdown LSP settings
vim.lsp.config("marksman", {
	capabilities = _G.lsp_common.lsp_capabilities,
	on_attach = _G.lsp_common.lsp_attach,
})

vim.lsp.enable("marksman")

-- XML LSP settings
vim.lsp.config("lemminx", {
	capabilities = _G.lsp_common.lsp_capabilities,
	on_attach = _G.lsp_common.lsp_attach,
})

vim.lsp.enable("lemminx")

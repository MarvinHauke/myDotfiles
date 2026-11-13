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
-- markdown-oxide wants dynamic file watching to see changes to other notes
vim.lsp.config("markdown_oxide", {
	capabilities = vim.tbl_deep_extend("force", _G.lsp_common.lsp_capabilities, {
		workspace = { didChangeWatchedFiles = { dynamicRegistration = true } },
	}),
	on_attach = _G.lsp_common.lsp_attach,
})

vim.lsp.enable("markdown_oxide")

-- XML LSP settings
vim.lsp.config("lemminx", {
	capabilities = _G.lsp_common.lsp_capabilities,
	on_attach = _G.lsp_common.lsp_attach,
})

vim.lsp.enable("lemminx")

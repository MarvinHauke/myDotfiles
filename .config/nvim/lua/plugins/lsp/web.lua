-- Web Development LSP Configuration

-- HTML LSP settings
vim.lsp.config("html", {
	capabilities = _G.lsp_common.lsp_capabilities,
	on_attach = _G.lsp_common.lsp_attach,
})

vim.lsp.enable("html")

-- CSS LSP settings
vim.lsp.config("cssls", {
	capabilities = _G.lsp_common.lsp_capabilities,
	on_attach = _G.lsp_common.lsp_attach,
})

vim.lsp.enable("cssls")

-- Quick Lint JS LSP settings
vim.lsp.config("quick_lint_js", {
	capabilities = _G.lsp_common.lsp_capabilities,
	on_attach = _G.lsp_common.lsp_attach,
})

vim.lsp.enable("quick_lint_js")

-- Svelte LSP settings
vim.lsp.config("svelte", {
	capabilities = _G.lsp_common.lsp_capabilities,
	on_attach = _G.lsp_common.lsp_attach,
})

vim.lsp.enable("svelte")

-- JSON LSP settings
vim.lsp.config("jsonls", {
	cmd = { "vscode-json-language-server", "--stdio" },
	filetypes = { "json", "jsonc" },
	capabilities = _G.lsp_common.lsp_capabilities,
	on_attach = _G.lsp_common.lsp_attach,
	settings = {
		json = {
			schemas = require("schemastore").json.schemas(),
			validate = { enable = true },
		},
	},
})

vim.lsp.enable("jsonls")

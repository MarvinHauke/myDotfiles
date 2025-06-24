-- Web Development LSP Configuration
local lspconfig = require("lspconfig")

-- HTML LSP settings
lspconfig.html.setup({
	capabilities = _G.lsp_common.lsp_capabilities,
	on_attach = _G.lsp_common.lsp_attach,
})

-- CSS LSP settings
lspconfig.cssls.setup({
	capabilities = _G.lsp_common.lsp_capabilities,
	on_attach = _G.lsp_common.lsp_attach,
})

-- JS/TS LSP settings
lspconfig.ts_ls.setup({
	capabilities = _G.lsp_common.lsp_capabilities,
	on_attach = function(client, bufnr)
		_G.lsp_common.lsp_attach(client, bufnr)

		-- Disable tsserver formatting if you prefer prettier
		client.server_capabilities.documentFormattingProvider = false
		client.server_capabilities.documentRangeFormattingProvider = false
	end,
})

-- Quick Lint JS LSP settings
lspconfig.quick_lint_js.setup({
	capabilities = _G.lsp_common.lsp_capabilities,
	on_attach = _G.lsp_common.lsp_attach,
})

-- Svelte LSP settings
lspconfig.svelte.setup({
	capabilities = _G.lsp_common.lsp_capabilities,
	on_attach = _G.lsp_common.lsp_attach,
})

-- JSON LSP settings
lspconfig.jsonls.setup({
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

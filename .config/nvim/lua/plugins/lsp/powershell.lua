-- PowerShell LSP Configuration
local lspconfig = require("lspconfig")

lspconfig.powershell_es.setup({
	capabilities = _G.lsp_common.lsp_capabilities,
	on_attach = _G.lsp_common.lsp_attach,
	settings = {
		powershell = {
			codeFormatting = {
				Preset = "OTBS",
			},
		},
	},
})

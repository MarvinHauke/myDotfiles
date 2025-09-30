-- PowerShell LSP Configuration
vim.lsp.config("powershell_es", {
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

vim.lsp.enable("powershell_es")

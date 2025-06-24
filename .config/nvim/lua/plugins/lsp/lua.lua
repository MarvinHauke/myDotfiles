-- Lua LSP Configuration
local lspconfig = require("lspconfig")

lspconfig.lua_ls.setup({
	capabilities = _G.lsp_common.lsp_capabilities,
	on_attach = _G.lsp_common.lsp_attach,
	settings = {
		Lua = {
			-- make language server recognize the `vim` global
			diagnostics = {
				globals = { "vim" },
			},
			workspace = {
				-- make language server aware of runtime files
				[vim.fn.expand("$VIMRUNTIME/lua")] = true,
				[vim.fn.stdpath("config") .. "/lua"] = true,
			},
		},
	},
})

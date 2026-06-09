-- JavaScript/TypeScript LSP Configuration (vtsls)

-- Altes ts_ls deaktivieren, damit kein zweiter Server parallel attached
vim.lsp.enable("ts_ls", false)

-- Custom on_attach für JS/TS
local js_lsp_attach = function(client, bufnr)
	_G.lsp_common.lsp_attach(client, bufnr)

	local map = function(mode, keys, func, desc)
		vim.keymap.set(mode, keys, func, {
			noremap = true,
			silent = true,
			buffer = bufnr,
			desc = desc,
		})
	end

	if client.server_capabilities.implementationProvider then
		map("n", "<leader>gi", vim.lsp.buf.implementation, "Go to Implementation")
	end

	map("n", "<leader>le", "<cmd>!eslint_d %<CR>", "Lint with eslint_d")
	map("n", "<leader>lx", "<cmd>!chmod +x %<CR>", "Make executable")
	map("n", "<leader>lr", "<cmd>!node %<CR>", "Run JavaScript with Node.js")
end

-- vtsls (JS/TS support)
vim.lsp.config("vtsls", {
	capabilities = _G.lsp_common.lsp_capabilities,
	on_attach = function(client, bufnr)
		client.server_capabilities.documentFormattingProvider = false
		js_lsp_attach(client, bufnr)
	end,
	settings = {
		vtsls = {
			autoUseWorkspaceTsdk = true, -- nutzt node_modules/typescript wie VSCode
		},
	},
})

vim.lsp.enable("vtsls")

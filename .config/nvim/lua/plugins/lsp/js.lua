-- JavaScript/TypeScript LSP Configuration

-- Custom on_attach for JavaScript
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

-- Setup tsserver (JS/TS support)
vim.lsp.config("ts_ls", {
	capabilities = _G.lsp_common.lsp_capabilities,
	on_attach = function(client, bufnr)
		-- Disable tsserver formatting if using prettier/eslint
		client.server_capabilities.documentFormattingProvider = false
		js_lsp_attach(client, bufnr)
	end,
	filetypes = {
		"javascript",
		"javascriptreact",
		"javascript.jsx",
		"typescript",
		"typescriptreact",
		"typescript.tsx",
	},
	root_dir = vim.fs.root(0, { "tsconfig.json", "package.json", ".git" }),
})

vim.lsp.enable("ts_ls")

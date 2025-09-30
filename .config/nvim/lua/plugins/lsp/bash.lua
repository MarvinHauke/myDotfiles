-- Bash LSP Configuration

-- Enhanced lsp_attach for bash files
local bash_lsp_attach = function(client, bufnr)
	_G.lsp_common.lsp_attach(client, bufnr) -- Call the standard attach function

	local map = function(mode, keys, func, desc)
		vim.keymap.set(mode, keys, func, {
			noremap = true,
			silent = true,
			buffer = bufnr,
			desc = desc,
		})
	end

	-- Conditional keymaps
	if client.server_capabilities.implementationProvider then
		map("n", "<leader>gi", vim.lsp.buf.implementation, "Go to Implementation")
	end

	-- Bash-specific keymaps
	map("n", "<leader>le", "<cmd>!shellcheck %<CR>", "Lint with shellcheck")
	map("n", "<leader>lx", "<cmd>!chmod +x %<CR>", "Make executable")
	map("n", "<leader>lr", "<cmd>!bash %<CR>", "Run bash script")
end

-- Enhanced Bash LSP settings
vim.lsp.config("bashls", {
	capabilities = _G.lsp_common.lsp_capabilities,
	on_attach = bash_lsp_attach,
	cmd = { "bash-language-server", "start" },
	filetypes = { "bash", "sh", "zsh" },
	root_dir = vim.fs.root(0, { ".git", ".bashrc", ".zshrc", ".bash_profile", "package.json" }),
	settings = {
		bashIde = {
			globPattern = "*@(.sh|.inc|.bash|.command|.zsh|.bashrc|.bash_profile|.bash_aliases|.zshrc|.profile)",
			enableSourceErrorDiagnostics = true,
			explainshellEndpoint = "https://explainshell.com/explain",
		},
	},
})

vim.lsp.enable("bashls")

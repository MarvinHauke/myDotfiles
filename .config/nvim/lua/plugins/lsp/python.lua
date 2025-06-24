-- Python LSP Configuration

-- Ruff LSP settings
vim.lsp.config("ruff", {
	on_attach = _G.lsp_common.lsp_attach,
	capabilities = _G.lsp_common.lsp_capabilities,
	settings = {
		args = {
			"--select=ALL",
			"--ignore=D100,D101,D102,D103,D104,D105,D106,D107",
			"--ignore=COM812,ISC001",
			"--line-length=88",
			"--target-version=py311",
		},
		organizeImports = true,
		fixAll = true,
	},
})

-- Pyright LSP settings
vim.lsp.config("pyright", {
	on_attach = _G.lsp_common.lsp_attach,
	capabilities = _G.lsp_common.lsp_capabilities,
	settings = {
		pyright = {
			-- Disable Pyright's formatting (let Ruff handle it)
			disableOrganizeImports = true,
		},
		python = {
			analysis = {
				-- Ignore all files for which we have Ruff enabled
				ignore = { "*" },
				-- Use Ruff for diagnostics
				typeCheckingMode = "strict", -- or "basic" or "off"
				autoSearchPaths = true,
				diagnosticMode = "workspace",
				useLibraryCodeForTypes = true,
			},
		},
	},
})

-- Python-specific autocommands
vim.api.nvim_create_autocmd("FileType", {
	pattern = "python",
	callback = function(args)
		local bufnr = args.buf

		vim.keymap.set("n", "<leader>lo", function()
			vim.lsp.buf.code_action({
				filter = function(action)
					return action.kind == "source.organizeImports"
				end,
				apply = true,
			})
		end, { buffer = bufnr, desc = "Organize imports" })

		vim.keymap.set("n", "<leader>lf", function()
			vim.lsp.buf.code_action({
				filter = function(action)
					return action.kind == "source.fixAll"
				end,
				apply = true,
			})
		end, { buffer = bufnr, desc = "Fix all issues" })
	end,
})

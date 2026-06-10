return {
  "neovim/nvim-lspconfig",
  event = "VeryLazy",
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    "j-hui/fidget.nvim",
    "folke/neodev.nvim",
  },
  config = function()
    require("mason").setup()
    require("mason-lspconfig").setup({
      ensure_installed = {
        "bashls",
        "cssls",
        "html",
        "lua_ls",
        "jsonls",
        "marksman",
        "pyright",
        "clangd",
        "ts_ls",
      },
      automatic_installation = true,
    })

    local lspconfig = require("lspconfig")
    local lsp_capabilities = require("cmp_nvim_lsp").default_capabilities()
    local mason_tool_installer = require("mason-tool-installer")
    require("fidget").setup({})

    local lsp_attach = function(client, bufnr) end

    require("mason-lspconfig").setup_handlers({
      function(server_name)
        lspconfig[server_name].setup({
          on_attach = lsp_attach,
          capabilities = lsp_capabilities,
        })
      end,
    })

    mason_tool_installer.setup({
      ensure_installed = {
        "prettier",
        "stylua",
        "ruff",
        "eslint_d",
        "shellcheck",
        "shfmt",
        "clang-format",
      },
    })

    lspconfig.lua_ls.setup({
      capabilities = lsp_capabilities,
      on_attach = lsp_attach,
      settings = {
        Lua = {
          diagnostics = {
            globals = { "vim" },
          },
          workspace = {
            [vim.fn.expand("$VIMRUNTIME/lua")] = true,
            [vim.fn.stdpath("config") .. "/lua"] = true,
          },
        },
      },
    })

    lspconfig.bashls.setup({
      capabilities = lsp_capabilities,
      on_attach = lsp_attach,
    })

    lspconfig.html.setup({
      capabilities = lsp_capabilities,
      on_attach = lsp_attach,
    })

    lspconfig.clangd.setup({
      capabilities = lsp_capabilities,
      on_attach = lsp_attach,
    })

    lspconfig.ts_ls.setup({
      capabilities = lsp_capabilities,
      on_attach = lsp_attach,
    })

    lspconfig.pyright.setup({
      capabilities = lsp_capabilities,
      on_attach = lsp_attach,
    })
  end,
}

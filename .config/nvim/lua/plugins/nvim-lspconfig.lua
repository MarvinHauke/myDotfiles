return {
  "williamboman/mason.nvim",
  dependencies = {
    "williamboman/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    "j-hui/fidget.nvim",
    "hrsh7th/cmp-nvim-lsp",
  },
  config = function()
    require("mason").setup()
    require("fidget").setup({})

    -- Apply cmp capabilities to all servers
    vim.lsp.config("*", {
      capabilities = require("cmp_nvim_lsp").default_capabilities(),
    })

    -- lua_ls needs custom settings for nvim development
    vim.lsp.config("lua_ls", {
      settings = {
        Lua = {
          diagnostics = { globals = { "vim" } },
          workspace = {
            [vim.fn.expand("$VIMRUNTIME/lua")] = true,
            [vim.fn.stdpath("config") .. "/lua"] = true,
          },
        },
      },
    })

    require("mason-lspconfig").setup({
      ensure_installed = {
        "bashls",
        "cssls",
        "html",
        "lua_ls",
        "jsonls",
        "marksman",
        "pyright",
        "ts_ls",
      },
      automatic_installation = true,
      handlers = {
        function(server_name)
          vim.lsp.enable(server_name)
        end,
      },
    })

    -- clangd is installed via apt (no arm64 Mason binary)
    vim.lsp.enable("clangd")

    require("mason-tool-installer").setup({
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
  end,
}

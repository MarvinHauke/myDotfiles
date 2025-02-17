return {
  -- LSP Configuration
  "neovim/nvim-lspconfig", -- https://github.com/neovim/nvim-lspconfig
  event = "VeryLazy",
  dependencies = {
    -- LSP Management
    "williamboman/mason.nvim",           -- https://github.com/williamboman/mason.nvim
    "williamboman/mason-lspconfig.nvim", -- https://github.com/williamboman/mason-lspconfig.nvim
    "WhoIsSethDaniel/mason-tool-installer.nvim",

    -- Useful status updates for LSP
    "j-hui/fidget.nvim", -- https://github.com/j-hui/fidget.nvim

    -- Additional lua configuration, makes nvim stuff amazing!
    "folke/neodev.nvim", -- https://github.com/folke/neodev.nvim
  },
  config = function()
    require("mason").setup()
    require("mason-lspconfig").setup({
      ensure_installed = {
        -- Update this list to the language servers you need installed
        "bashls",
        "cssls",
        "tailwindcss",
        "html",
        "svelte",
        "lua_ls",
        "jsonls",
        "lemminx",
        "marksman",
        "quick_lint_js",
        "powershell_es",
        "pyright",
        "lemminx",
        "clangd",
      },
      automatic_installation = true,
    })
    local lspconfig = require("lspconfig")
    local lsp_capabilities = require("cmp_nvim_lsp").default_capabilities() -- INFO Search for difference between default_capabilities and normal capabilities
    local mason_tool_installer = require("mason-tool-installer")
    require("fidget").setup({})

    local lsp_attach = function(client, bufnr)
      -- Create your attached keybindings here..
    end

    -- Call setup on each LSP server
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
        "prettier", -- prettier formatter
        "stylua",   -- lua formatter
        "isort",    -- python formatter
        "black",    -- python formatter
        "pylint",   -- python linter
        "prittier", -- js formatter
        "eslint_d", -- js linter
      },
    })

    -- Lua LSP settings
    lspconfig.lua_ls.setup({
      capabilities = lsp_capabilities,
      on_attach = lsp_attach,
      settings = { -- custom settings for lua
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

    -- Bash LSP settings
    lspconfig.bashls.setup({
      capabilities = lsp_capabilities,
      on_attach = lsp_attach,
    })

    -- PowerShell LSP settings
    lspconfig.powershell_es.setup({
      capabilities = lsp_capabilities,
      on_attach = lsp_attach,
      settings = { -- custom settings for powershell
        powershell = {
          codeFormatting = {
            Preset = "OTBS",
          },
        },
      },
    })

    -- HTML LSP settings
    lspconfig.html.setup({
      capabilities = lsp_capabilities,
      on_attach = lsp_attach,
    })

    -- C++ LSP settings
    lspconfig.clangd.setup({
      capabilities = lsp_capabilities,
      on_attach = lsp_attach,
    })

    -- JS LSP settings
    lspconfig.ts_ls.setup({
      capabilities = lsp_capabilities,
      on_attach = lsp_attach,
    })

    -- Python LSP settings
    lspconfig.pyright.setup({
      capabilities = lsp_capabilities,
      on_attach = lsp_attach,
    })
  end,
}

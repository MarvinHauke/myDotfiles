return {
  -- LSP Configuration
  -- https://github.com/neovim/nvim-lspconfig
  'neovim/nvim-lspconfig',
  event = 'VeryLazy',
  dependencies = {
    -- LSP Management
    -- https://github.com/williamboman/mason.nvim
    { 'williamboman/mason.nvim' },

    -- https://github.com/williamboman/mason-lspconfig.nvim
    { 'williamboman/mason-lspconfig.nvim' },

    -- Useful status updates for LSP
    -- https://github.com/j-hui/fidget.nvim
    { 'j-hui/fidget.nvim' },

    -- Additional lua configuration, makes nvim stuff amazing!
    -- https://github.com/folke/neodev.nvim
    { 'folke/neodev.nvim' },
  },
  config = function()
    require('mason').setup()
    require('mason-lspconfig').setup({
      -- Update this list to the language servers you need installed
      ensure_installed = {
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
        "tsserver",
        "pyright"
      },
      automatic_installation = true,
    })

    local lspconfig = require('lspconfig')
    local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities()

    local lsp_attach = function(client, bufnr)
      -- Create your attached keybindings here..
    end

    -- Call setup on each LSP server
    require('mason-lspconfig').setup_handlers({
      function(server_name)
        lspconfig[server_name].setup({
          on_attach = lsp_attach,
          capabilities = lsp_capabilities,
        })
      end
    })

    -- Lua LSP settings
    lspconfig.lua_ls.setup({
      capabilities = lsp_capabilities,
      on_attach = lsp_attach,
      settings = { -- custom settings for lua
        Lua = {
          -- make language server recognize the `vim` global
          diagnostics = {
            globals = { 'vim' },
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
      on_attach = lsp_attach
    })

    -- PowerShell LSP settings
    lspconfig.powershell_es.setup({
      capabilities = lsp_capabilities,
      on_attach = lsp_attach,
      settings = { -- custom settings for powershell
        powershell = {
          codeFormatting = {
            Preset = 'OTBS' },
        },
      },
    })

    -- C++ LSP settings
    lspconfig.clangd.setup({
      capabilities = lsp_capabilities,
      on_attach = lsp_attach,
    })

    -- JS LSP settings
    lspconfig.tsserver.setup({
      capabilities = lsp_capabilities,
      on_attach = lsp_attach,
    })

    -- Python LSP settings
    lspconfig.pyright.setup({
      capabilities = lsp_capabilities,
      on_attach = lsp_attach,
    })

    lspconfig.clangd.setup({
      capabilities = lsp_capabilities,
      on_attach = lsp_attach
    })
  end
}

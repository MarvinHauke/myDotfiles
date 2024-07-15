-- Auto-completion / Snippets
return {

  "hrsh7th/nvim-cmp", -- https://github.com/hrsh7th/nvim-cmp
  event = "InsertEnter",
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig",

    -- Snippet engine & associated nvim-cmp source
    "L3MON4D3/LuaSnip", -- https://github.com/L3MON4D3/LuaSnip

    -- https://github.com/saadparwaiz1/cmp_luasnip
    "saadparwaiz1/cmp_luasnip", -- for autocompletion

    -- https://github.com/rafamadriz/friendly-snippets
    "rafamadriz/friendly-snippets", --useful snippets

    -- https://github.com/hrsh7th/cmp-nvim-lsp
    "hrsh7th/cmp-nvim-lsp", -- LSP completion capabilities

    -- https://github.com/hrsh7th/cmp-buffer
    "hrsh7th/cmp-buffer", -- source for text in buffer

    -- https://github.com/hrsh7th/cmp-path
    "hrsh7th/cmp-path", -- source for file system paths

    -- https://github.com/hrsh7th/cmp-cmdline
    "hrsh7th/cmp-cmdline",
  },
  config = function()
    local cmp = require("cmp")
    local luasnip = require("luasnip")

    -- loads vscode style snippets from installed plugins (e.g. friendly-snippets)
    require("luasnip.loaders.from_vscode").lazy_load()
    cmp.setup({
      completion = {
        completeopt = "menu,menuone,preview,noselect",
      },
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
      },
      mapping = cmp.mapping.preset.insert({
        ["<C-k>"] = cmp.mapping.select_prev_item(),         -- previous suggestion
        ["<S-Tab>"] = cmp.mapping.select_prev_item(),       -- previous suggestion
        ["<C-j>"] = cmp.mapping.select_next_item(),         -- next suggestion
        ["<Tab>"] = cmp.mapping.select_next_item(),         -- next suggestion
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),            -- scroll backward
        ["<C-f>"] = cmp.mapping.scroll_docs(4),             -- scroll forward
        ["<C-Space>"] = cmp.mapping.complete(),             -- show completion suggestions
        ["<C-e>"] = cmp.mapping.abort(),                    -- clear completion window
        ["<CR>"] = cmp.mapping.confirm({ select = false }), -- confirm selection
      }),
      sources = cmp.config.sources({
        --        { name = "nvim_lsp" }, -- lsp
        { name = "luasnip" }, -- snippets
        { name = "buffer" },  -- text within current buffer
        { name = "path" },    -- file system paths
        { name = "neorg" },   -- neorg
      }),
    })
  end,
}

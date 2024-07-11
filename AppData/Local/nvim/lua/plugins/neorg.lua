return {
  {
    "vhyrro/luarocks.nvim",
    priority = 1000,
    config = true,
  },
  {
    "nvim-neorg/neorg",
    dependencies = { "luarocks.nvim" },
    version = "*",
    config = function()
      require("neorg").setup {
        load = {
          ["core.defaults"] = {},
          ["core.concealer"] = {},
          ["core.integrations.treesitter"] = {},
          ["core.itero"] = {},
          ["core.export"] = {},
          ["core.export.markdown"] = {
            config = {
              extensions = "all"
            }
          },
          ["core.dirman"] = {
            config = {
              workspaces = {
                notes = "~/OneDrive - Pikes GmbH/Dokumente/Notizen",
              },
              default_workspace = "notes",
            },
          },
          ["core.dirman.utils"] = {},
          ["core.completion"] = {
            config = {
              engine = "nvim-cmp",
            },
          },
        },
        ["core.ui.calendar"] = {},
        -- dependencies = { "nvim-lua/plenary.nvim" },
      }

      vim.wo.foldlevel = 99
      vim.wo.conceallevel = 2
    end,
  }
}

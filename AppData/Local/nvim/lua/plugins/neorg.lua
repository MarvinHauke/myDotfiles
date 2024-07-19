return {
  {
    "vhyrro/luarocks.nvim",
    priority = 1000,
    config = true,
  },
  {
    "nvim-neorg/neorg",
    build = ":Neorg sync-parsers",
    dependencies = {
      "luarocks.nvim",
      "nvim-lua/plenary.nvim"
    },
    version = "*",
    config = function()
      require("neorg").setup {
        load = {
          ["core.defaults"] = {},
          ["core.concealer"] = {
            config = {
              folds = false,
              icon_preset = "diamond",
            },
          },
          ["core.integrations.treesitter"] = {
            config = {
              install_parsers = true
            },
          },
          ["core.export"] = {},
          ["core.export.markdown"] = {
            config = {
              extensions = "all"
            }
          },
          ["core.dirman"] = {
            config = {
              workspaces = {
                notes = "~/Documents/Notizen",
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
        ["core.ui"] = {},
        ["core.ui.calendar"] = {},
      }
      vim.wo.foldlevel = 99
      vim.wo.conceallevel = 2
    end,
  }
}

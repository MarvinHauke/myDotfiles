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
          ["core.concealer"] = {
            config = {
              icons = {
                todo = {
                  on_hold = {
                    icon = ""
                  },
                  uncertain = {
                    icon = ""
                  },
                },
              },
            },
          },
          ["core.integrations.treesitter"] = {},
          ["core.itero"] = {},
          ["core.export"] = {
            config = {
              extensions = { "all" },
            },
          },
          ["core.export.markdown"] = {},
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
        ["core.ui.calendar"] = {},
        dependencies = { "nvim-lua/plenary.nvim" },
      }
      vim.wo.foldlevel = 99
      vim.wo.conceallevel = 2
    end,
  }
}

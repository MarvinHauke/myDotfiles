return {
  "stevearc/oil.nvim",
  opts = {},
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local oil = require("oil")

    oil.setup({
      default_file_explorer = true,
      delete_to_trash = true,
      skip_confirm_for_simple_edits = false,
      view_options = {
        show_hidden = true,
        natural_order = true,
        case_insensitive = false,
        is_always_hidden = function(name, _)
          return name == ".." or name == ".git"
        end,
      },
      float = {
        padding = 2,
        max_width = 120,
        max_height = 0,
      },
      preview_split = "right",
      preview_win = {
        update_on_cursor_moved = true,
        preview_method = "fast_scratch",
        disable_preview = function()
          return false
        end,
        win_options = {},
      },

      keymaps = {
        ["<C-c>"] = false,
        ["<ESC>"] = "actions.close",
      },
    })
  end,
}

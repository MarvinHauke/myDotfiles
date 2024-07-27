-- Fuzzy finder
return {
  -- https://github.com/nvim-telescope/telescope.nvim
  'nvim-telescope/telescope.nvim',
  lazy = true,
  branch = '0.1.x',
  dependencies = {
    -- https://github.com/nvim-lua/plenary.nvim
    { 'nvim-lua/plenary.nvim' },

    -- https://github.com/nvim-telescope/telescope-fzf-native.nvim
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make',
      cond = function()
        return vim.fn.executable 'make' == 1
      end,
    },
  },
  opts = {
    defaults = {
      layout_config = {
        vertical = {
          width = 0.75
        }
      }
    }
  },
  keys = {
    { "<leader>ff", ":Telescope find_files<cr>",                desc = "find files" },
    { "<leader>fg", ":Telescope live_grep<cr>",                 desc = "live grep" },
    { "<leader>fb", ":Telescope buffers<cr>",                   desc = "buffers" },
    { "<leader>fh", ":Telescope help_tags<cr>",                 desc = "help tags" },
    { "<leader>fs", ":Telescope current_buffer_fuzzy_find<cr>", desc = "current buffer fuzzy find" },
    { "<leader>fo", ":Telescope lsp_document_symbols<cr>",      desc = "lsp document symbols" },
    { "<leader>fi", ":Telescope lsp_incoming_calls<cr>",        desc = "lsp incoming calls" },

    vim.keymap.set("n", "<leader>fm", function()
      require("telescope.builtin").treesitter({ default_text = ":method:" })
    end)
  }
}

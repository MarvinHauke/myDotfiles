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
    { "<leader>ff", ":Telescope find_files<cr>" },
    { "<leader>fg", ":Telescope live_grep<cr>" },
    { "<leader>fb", ":Telescope buffers<cr>" },
    { "<leader>fh", ":Telescope help_tags<cr>" },
    { "<leader>fs", ":Telescope current_buffer_fuzzy_find<cr>" },
    { "<leader>fo", ":Telescope lsp_document_symbols<cr>" },
    { "<leader>fi", ":Telescope lsp_incoming_calls<cr>" },

    vim.keymap.set("n", "<leader>fm", function()
      require("telescope.builtin").treesitter({ default_text = ":method:" })
    end)
  }
}

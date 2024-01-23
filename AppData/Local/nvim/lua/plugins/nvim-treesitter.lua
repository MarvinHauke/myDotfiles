-- Code Tree Support / Syntax Highlighting
return {
  -- https://github.com/nvim-treesitter/nvim-treesitter
  'nvim-treesitter/nvim-treesitter',
  event = 'VeryLazy',
  dependencies = {
    -- https://github.com/nvim-treesitter/nvim-treesitter-textobjects
    'nvim-treesitter/nvim-treesitter-textobjects',
    -- https://github.com/nvim-treesitter/playground
    'nvim-treesitter/playground',
  },
  build = ':TSUpdate',
  opts = {
    highlight = {
      enable = true,
    },
    indent = { enable = true },
    auto_install = true, -- automatically install syntax support when entering new file type buffer
    ensure_installed = {
      'lua',
      'python',
      'javascript',
      'vim',
      'html',
    },
  },
  config = function(_, opts)
    local configs = require('nvim-treesitter.configs')

    -- this was added for powershell config may delete it
    local parser_config = require 'nvim-treesitter.parsers'.get_parser_configs()
    parser_config.powershell = {
      install_info = {
        url = "C:/Users/MarvinHauke/Development/Github/tree-sitter-PowerShell",
        files = { "src/parser.c", "src/scanner.c" },
        branch = "main",
        generate_requires_npm = false,
        requires_generate_from_grammar = false,
      },
      filetype = "ps1",
    }
    -- this was added for powershell config may delete it

    configs.setup(opts)
  end
}

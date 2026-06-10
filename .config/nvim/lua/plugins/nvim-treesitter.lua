return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  main = "nvim-treesitter",
  opts = {
    ensure_installed = {
      "c",
      "lua",
      "bash",
      "python",
      "javascript",
      "vim",
      "html",
      "json",
    },
    highlight = { enable = true },
    indent = { enable = true },
    auto_install = true,
  },
}

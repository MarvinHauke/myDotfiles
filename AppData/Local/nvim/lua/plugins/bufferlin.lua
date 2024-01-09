return {
  'akinsho/bufferline.nvim',
  version = "*",
  dependencies = {
    'nvim-tree/nvim-web-devicons',
  },
  opts = {
    options = {
      offsets = {
        {
          filetype = "NvimTree",
          text = "File Explorer",
          highlight = "Directory",
          seperator = true,
        }
      },
      hover = {
        enabled = true,
        delay = 150,
        reveal = { 'close' }
      },
    },
  },
}

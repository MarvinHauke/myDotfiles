return {
  'akinsho/bufferline.nvim',
  version = "*",
  dependencies = {
    'nvim-tree/nvim-web-devicons',
    'ojroques/nvim-bufdel'
  },
  opts = {
    options = {
      mode = "buffers",
      hover = {
        enabled = true,
        delay = 150,
        reveal = { 'close' }
      },
      indicator = {
        style = 'underline'
      },
    }
  }
}

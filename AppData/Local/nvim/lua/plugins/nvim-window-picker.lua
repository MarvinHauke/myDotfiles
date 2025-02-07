return {
  's1n7ax/nvim-window-picker',
  name = 'window-picker',
  event = 'VeryLazy',
  version = '2.*',
  config = function()
    require('window-picker').setup({
      hint = "statusline-winbar",
      selection_chars = 'FJDKSLA;CMRUEIWOQP',
      show_prompt = true,
    })
  end,
}

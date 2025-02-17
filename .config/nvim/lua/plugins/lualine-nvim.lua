return {
  -- https://github.com/nvim-lualine/lualine.nvim
  'nvim-lualine/lualine.nvim',
  dependencies = {
    -- https://github.com/nvim-tree/nvim-web-devicons
    'nvim-tree/nvim-web-devicons',    -- Fancy icons
    -- https://github.com/linrongbin16/lsp-progress.nvim
    'linrongbin16/lsp-progress.nvim', -- LSP loading progress
  },
  opts = {
    options = {
      theme = 'dracula', -- lualine theme
      icons_enabled = true,
      component_separators = { left = '', right = '' },
      section_separators = { left = '', right = '' },
    },
    sections = {
      lualine_a = { 'mode' },
      lualine_b = { 'branch' },
      lualine_c = {
        {
          -- Display LSP clients attached to the buffer
          function()
            local bufnr = vim.api.nvim_get_current_buf()
            local clients = vim.lsp.get_active_clients({ bufnr = bufnr })
            if next(clients) == nil then
              return ''
            end
            local c = {}
            for _, client in pairs(clients) do
              table.insert(c, client.name)
            end
            return ' ' .. table.concat(c, ' | ') -- Gear icon for LSP
          end,
          icon = '',
          color = { fg = "#98c379", gui = "bold" },
        },
        {
          -- Customize the filename part of lualine to be parent/filename
          'filename',
          file_status = true,     -- Displays file status (readonly status, modified status)
          newfile_status = false, -- Display new file status
          path = 4,               -- 4: Filename and parent dir, with tilde as the home directory
          symbols = {
            modified = '[+]',     -- Text to show when the file is modified.
            readonly = '[-]',     -- Text to show when the file is readonly.
          }
        }
      },
      lualine_x = { 'encoding', 'fileformat', 'filetype' },
      lualine_y = { 'progress' },
      lualine_z = { 'location' }
    }
  }
}

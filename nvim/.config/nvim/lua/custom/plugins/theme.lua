-- Colorscheme with automatic light/dark mode switching

return {
  'folke/tokyonight.nvim',
  priority = 1000, -- Make sure to load this before all the other start plugins
  config = function()
    -- Function to check macOS appearance and set colorscheme
    local function check_appearance()
      local theme = vim.fn.system('defaults read -g AppleInterfaceStyle'):gsub('\n', '')
      if theme == 'Dark' then
        vim.o.background = 'dark'
        vim.cmd.colorscheme 'tokyonight-night'
      else
        vim.o.background = 'light'
        vim.cmd.colorscheme 'tokyonight-day'
      end
    end

    -- Set initial theme
    check_appearance()

    -- Auto-switch theme when focus is gained (macOS appearance change)
    vim.api.nvim_create_autocmd('FocusGained', {
      callback = function()
        check_appearance()
        -- Refresh lualine theme
        local lualine_loaded, lualine = pcall(require, 'lualine')
        if lualine_loaded then
          lualine.setup { theme = 'auto' }
        end
      end,
    })
  end,
}

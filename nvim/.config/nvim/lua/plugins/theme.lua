vim.api.nvim_create_user_command('ThemeDay', function()
  vim.cmd.colorscheme 'catppuccin-latte'
end, {})

vim.api.nvim_create_user_command('ThemeNight', function()
  vim.cmd.colorscheme 'tokyonight-storm'
end, {})

return {
  {
    'folke/tokyonight.nvim',
    lazy = false,
    priority = 1001,
    opts = {},
    config = function()
      vim.cmd.colorscheme 'tokyonight-storm'
    end,
  },
  {
    'catppuccin/nvim',
    priority = 1000,
    config = function()
      -- vim.cmd.colorscheme 'catppuccin'
    end,
  },
  {
    'vimpostor/vim-lumen',
    lazy = false,
    priority = 999,
    init = function()
      vim.cmd [[
        au User LumenLight colorscheme catppuccin-latte
        au User LumenDark colorscheme tokyonight-storm
      ]]
    end,
  },
}

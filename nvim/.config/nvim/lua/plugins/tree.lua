return {
  'kyazdani42/nvim-tree.lua',
  dependencies = {
    'kyazdani42/nvim-web-devicons',
  },
  lazy = false,
  keys = {
    { '\\', '<cmd>NvimTreeFindFile<cr>', desc = 'Find file in filetree' },
  },
  opts = {
    filters = {
      custom = { '.git', 'node_modules', '.vscode' },
      dotfiles = false,
    },
    git = {},
    view = {
      adaptive_size = true,
      float = {
        enable = true,
      },
    },
  },
}

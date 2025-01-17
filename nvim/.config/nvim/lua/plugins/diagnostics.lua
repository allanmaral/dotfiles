vim.diagnostic.config {
  underline = true,
  update_in_insert = false,
  virtual_text = false,
  document_highlight = {
    enabled = true,
  },
  capabilities = {
    workspace = {
      fileOperations = {
        didRename = true,
        willRename = true,
      },
    },
  },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = '',
      [vim.diagnostic.severity.WARN] = '',
      [vim.diagnostic.severity.INFO] = '󰙎',
      [vim.diagnostic.severity.HINT] = '󰌶',
    },
  },
  severity_sort = true,
}

return {
  {
    'rachartier/tiny-inline-diagnostic.nvim',
    event = 'LspAttach',
    config = function()
      require('tiny-inline-diagnostic').setup {
        preset = 'powerline',
        options = {
          -- add_messages = false,
          multilines = {
            enabled = true,
            always_show = false,
          },
          virt_texts = {
            priority = 2048,
          },
          show_all_diags_on_cursorline = true,
          multiple_diag_under_cursor = true,
          -- show_source = true,
          format = function(diagnostic)
            if diagnostic.source == 'eslint' then
              return string.format(
                '%s [%s]',
                diagnostic.message,
                -- shows the name of the rule
                diagnostic.user_data.lsp.code
              )
            end
            return string.format('%s [%s]', diagnostic.message, diagnostic.source)
          end,
        },
      }
    end,
  },
}

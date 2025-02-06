-- local set_kind = function(kind, items)lsp
--   local CompletionItemKind = require('blink.cmp.types').CompletionItemKind
--   local kind_idx = #CompletionItemKind + 1
--   CompletionItemKind[kind_idx] = 'LSP'
--   for _, item in ipairs(items) do
--     item.kind = kind_idx
--   end
--   return items
-- end
--
-- local with_kind = function(kind)
--   return function(items)
--     return set_kind(kind, items)
--   end
-- end

return {
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = 'luvit-meta/library', words = { 'vim%.uv' } },
      },
    },
  },
  { 'Bilal2453/luvit-meta', lazy = true },

  {
    -- Main LSP Configuration
    'neovim/nvim-lspconfig',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      -- 'saghen/blink.cmp',
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      { 'j-hui/fidget.nvim', opts = {} },
    },
    config = function()
      local lspconfig_defaults = require('lspconfig').util.default_config
      lspconfig_defaults.capabilities = vim.tbl_deep_extend('force', lspconfig_defaults.capabilities, require('cmp_nvim_lsp').default_capabilities())
      -- lspconfig_defaults.capabilities = vim.tbl_deep_extend('force', lspconfig_defaults.capabilities, require('blink.cmp').get_lsp_capabilities())

      vim.api.nvim_create_autocmd('LspAttach', {
        desc = 'LSP actions',
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
          map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
          map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
          map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
          map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
          map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
          map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
          map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })
          map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, '[T]oggle Inlay [H]ints')
          end

          -- The following two autocommands are used to highlight references of the
          -- word under your cursor when your cursor rests there for a little while.
          --    See `:help CursorHold` for information about when this is executed
          --
          -- When you move your cursor, the highlights will be cleared (the second autocommand).
          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
            local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
              end,
            })
          end
        end,
      })

      local utils = require 'lspconfig/util'

      -- vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, {
      --   border = 'rounded',
      -- })

      local servers = {
        gopls = {},
        rust_analyzer = {
          filetypes = { 'rust' },
          root_dir = utils.root_pattern 'Cargo.toml',
          settings = {
            ['rust-analyzer'] = {
              cargo = {
                allFeatures = true,
              },
            },
          },
        },
        vtsls = {
          root_dir = utils.root_pattern('pnpm-workspace.yaml', 'pnpm-lock.yaml', 'yarn.lock', 'package-lock.json', 'bun.lockb'),
          typescript = {
            tsserver = {
              maxTsServerMemory = 12288,
            },
          },
          experimental = {
            completion = {
              entriesLimit = 3,
            },
          },
        },
        tailwindcss = {},
        eslint = {
          filetypes = {
            'html.mustache',
            'javascript',
            'javascriptreact',
            'javascript.jsx',
            'typescript',
            'typescriptreact',
            'typescript.tsx',
            'vue',
            'svelte',
            'astro',
            'mustache',
            'html',
          },
          -- on_attach = function(_, bufnr)
          --   vim.api.nvim_create_autocmd('BufWritePre', {
          --     buffer = bufnr,
          --     command = 'EslintFixAll',
          --   })
          -- end,
          settings = {
            workingDirectories = { mode = 'auto' },
            rulesCustomizations = {
              { rule = 'prettier/prettier', severity = 'off' },
            },
          },
        },
        lua_ls = {
          settings = {
            Lua = {
              completion = {
                callSnippet = 'Replace',
              },
            },
          },
        },
        terraformls = {},
      }

      require('mason').setup()

      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        'stylua', -- Used to format Lua code
        'prettierd',
      })
      -- local skip_mason = { 'zls' }
      --
      -- local skip_set = {}
      -- for _, item in ipairs(skip_mason) do
      --   skip_set[item] = true
      -- end
      -- for i, _ in ipairs(ensure_installed) do
      --   if skip_set[ensure_installed[i]] then
      --     table.remove(ensure_installed, i)
      --   end
      -- end

      local lspconfig = require 'lspconfig'
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }
      require('mason-lspconfig').setup {
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            -- This handles overriding only values explicitly passed
            -- by the server configuration above. Useful when disabling
            -- certain features of an LSP (for example, turning off formatting for ts_ls)
            -- server.capabilities = require('blink.cmp').get_lsp_capabilities(server.capabilities)
            server.capabilities = vim.tbl_deep_extend('force', {}, lspconfig_defaults.capabilities, server.capabilities or {})
            require('lspconfig')[server_name].setup(server)
          end,
        },
      }

      lspconfig.zls.setup {
        capabilities = lspconfig_defaults.capabilities,
        settings = { zls = {} },
      }
    end,
  },

  -- {
  --   'saghen/blink.cmp',
  --   version = 'v0.9.3',
  --   dependencies = {
  --     {
  --       'giuxtaposition/blink-cmp-copilot',
  --     },
  --   },
  --   ---@module 'blink.cmp'
  --   ---@type blink.cmp.Config
  --   opts = {
  --     -- 'default' for mappings similar to built-in completion
  --     -- 'super-tab' for mappings similar to vscode (tab to accept, arrow keys to navigate)
  --     -- 'enter' for mappings similar to 'super-tab' but with 'enter' to accept
  --     -- See the full "keymap" documentation for information on defining your own keymap.
  --     keymap = {
  --       preset = 'default',
  --     },
  --
  --     enabled = function()
  --       return not vim.tbl_contains({ 'markdown' }, vim.bo.filetype) and vim.bo.buftype ~= 'prompt' and vim.b.completion ~= false
  --     end,
  --
  --     completion = {
  --       documentation = {
  --         auto_show = true,
  --         auto_show_delay_ms = 500,
  --       },
  --
  --       ghost_text = { enabled = true },
  --
  --       menu = {
  --         -- auto_show = function(ctx)
  --         --   return ctx.mode ~= 'cmdline'
  --         -- end,
  --         -- Customize the appearance of the completion menu
  --         winhighlight = 'Normal:Pmenu,FloatBorder:Pmenu,CursorLine:PmenuSel,Search:None',
  --         -- Additional appearance settings
  --         min_width = 15,
  --         max_height = 10,
  --         border = 'none',
  --         winblend = 0,
  --         scrollbar = true,
  --         direction_priority = { 's', 'n' },
  --       },
  --     },
  --
  --     appearance = {
  --       -- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
  --       nerd_font_variant = 'mono',
  --       kind_icons = {
  --         Copilot = '',
  --         Text = '󰉿',
  --         Method = '󰊕',
  --         Function = '󰊕',
  --         Constructor = '󰒓',
  --
  --         Field = '󰜢',
  --         Variable = '󰆦',
  --         Property = '󰖷',
  --
  --         Class = '󱡠',
  --         Interface = '󱡠',
  --         Struct = '󱡠',
  --         Module = '󰅩',
  --
  --         Unit = '󰪚',
  --         Value = '󰦨',
  --         Enum = '󰦨',
  --         EnumMember = '󰦨',
  --
  --         Keyword = '󰻾',
  --         Constant = '󰏿',
  --
  --         Snippet = '󱄽',
  --         Color = '󰏘',
  --         File = '󰈔',
  --         Reference = '󰬲',
  --         Folder = '󰉋',
  --         Event = '󱐋',
  --         Operator = '󰪚',
  --         TypeParameter = '󰬛',
  --       },
  --     },
  --
  --     -- Default list of enabled providers defined so that you can extend it
  --     -- elsewhere in your config, without redefining it, due to `opts_extend`
  --     sources = {
  --       default = { 'lsp', 'path', 'snippets', 'buffer', 'copilot' },
  --       providers = {
  --         lsp = {
  --           name = 'lsp',
  --           enabled = true,
  --           module = 'blink.cmp.sources.lsp',
  --           score_offset = 90, -- the higher the number, the higher the priority
  --           transform_items = with_kind 'LSP',
  --         },
  --         path = {
  --           name = 'Path',
  --           module = 'blink.cmp.sources.path',
  --           score_offset = 25,
  --           -- When typing a path, I would get snippets and text in the
  --           -- suggestions, I want those to show only if there are no path
  --           -- suggestions
  --           fallbacks = { 'snippets', 'buffer' },
  --           opts = {
  --             trailing_slash = false,
  --             label_trailing_slash = true,
  --             get_cwd = function(context)
  --               return vim.fn.expand(('#%d:p:h'):format(context.bufnr))
  --             end,
  --             show_hidden_files_by_default = true,
  --           },
  --         },
  --         buffer = {
  --           name = 'Buffer',
  --           enabled = true,
  --           max_items = 3,
  --           module = 'blink.cmp.sources.buffer',
  --           min_keyword_length = 4,
  --           score_offset = 15, -- the higher the number, the higher the priority
  --         },
  --         copilot = {
  --           name = 'copilot',
  --           module = 'blink-cmp-copilot',
  --           score_offset = -100,
  --           async = true,
  --           transform_items = with_kind 'Copilot',
  --         },
  --       },
  --     },
  --   },
  --
  --   opts_extend = { 'sources.default' },
  --
  --   signature = { enabled = true },
  -- },

  { -- Autocompletion
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      {
        'L3MON4D3/LuaSnip',
        build = (function()
          -- Build Step is needed for regex support in snippets.
          -- This step is not supported in many windows environments.
          -- Remove the below condition to re-enable on windows.
          if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
            return
          end
          return 'make install_jsregexp'
        end)(),
      },
      'saadparwaiz1/cmp_luasnip',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
      'onsails/lspkind.nvim',
      -- 'zbirenbaum/copilot-cmp',
    },
    config = function()
      local cmp = require 'cmp'
      local luasnip = require 'luasnip'
      local lspkind = require 'lspkind'
      -- local copilot = require 'copilot_cmp'
      luasnip.config.setup {}
      -- copilot.setup()

      local cmp_kinds = {
        Text = '  ',
        Method = '  ',
        Function = '  ',
        Constructor = '  ',
        Field = '  ',
        Variable = '  ',
        Class = '  ',
        Interface = '  ',
        Module = '  ',
        Property = '  ',
        Unit = '  ',
        Value = '  ',
        Enum = '  ',
        Keyword = '  ',
        Snippet = '  ',
        Color = '  ',
        File = '  ',
        Reference = '  ',
        Folder = '  ',
        EnumMember = '  ',
        Constant = '  ',
        Struct = '  ',
        Event = '  ',
        Operator = '  ',
        TypeParameter = '  ',
        Copilot = ' ',
      }

      cmp.setup {
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        completion = { completeopt = 'menu,menuone,noinsert' },

        mapping = cmp.mapping.preset.insert {
          -- Select the [n]ext item
          ['<C-n>'] = cmp.mapping.select_next_item(),
          -- Select the [p]revious item
          ['<C-p>'] = cmp.mapping.select_prev_item(),

          -- Scroll the documentation window [b]ack / [f]orward
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),

          -- Accept ([y]es) the completion.
          --  This will auto-import if your LSP supports it.
          --  This will expand snippets if the LSP sent a snippet.
          ['<C-y>'] = cmp.mapping.confirm { select = true },
          -- ['<CR>'] = cmp.mapping.confirm { select = true },

          -- If you prefer more traditional completion keymaps,
          -- you can uncomment the following lines
          --['<CR>'] = cmp.mapping.confirm { select = true },
          --['<Tab>'] = cmp.mapping.select_next_item(),
          --['<S-Tab>'] = cmp.mapping.select_prev_item(),

          -- Manually trigger a completion from nvim-cmp.
          --  Generally you don't need this, because nvim-cmp will display
          --  completions whenever it has completion options available.
          ['<C-Space>'] = cmp.mapping.complete {},

          -- Think of <c-l> as moving to the right of your snippet expansion.
          --  So if you have a snippet that's like:
          --  function $name($args)
          --    $body
          --  end
          --
          -- <c-l> will move you to the right of each of the expansion locations.
          -- <c-h> is similar, except moving you backwards.
          ['<C-l>'] = cmp.mapping(function()
            if luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            end
          end, { 'i', 's' }),
          ['<C-h>'] = cmp.mapping(function()
            if luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            end
          end, { 'i', 's' }),
        },
        sources = {
          { name = 'lazydev', group_index = 0, priority = 30, max_item_count = 3 },
          { name = 'nvim_lsp', priority = 10 },
          { name = 'luasnip', priority = 15, max_item_count = 5 },
          { name = 'path', priority = 75 },
          -- { name = 'copilot', priority = 100 },
        },
        window = {
          completion = {
            winhighlight = 'Normal:Pmenu,FloatBorder:Pmenu,Search:None',
            col_offset = -3,
            side_padding = 0,
          },
        },
        formatting = {
          fields = { 'kind', 'abbr', 'menu' },
          format = function(_, vim_item)
            vim_item.kind = cmp_kinds[vim_item.kind] or ''
            vim_item.menu = string.sub(vim_item.menu or '', 1, 18)
            return vim_item
          end,
          -- format = function(entry, vim_item)
          --   local kind = lspkind.cmp_format { mode = 'symbol_text', maxwidth = 50 }(entry, vim_item)
          --   local strings = vim.split(kind.kind, '%s', { trimempty = true })
          --   kind.kind = ' ' .. (strings[1] or '') .. ' '
          --   -- kind.menu = "    (" .. (strings[2] or "") .. ")"
          --
          --   return kind
          -- end,
        },

        -- window = {
        --   completion = { border = 'rounded' },
        --   documentation = { border = 'rounded' },
        -- },

        -- formatting = {
        --   -- fields = { 'menu', 'abbr', 'kind' },
        --   format = function(entry, item)
        --     local entryItem = entry.completion_item
        --     -- local entryItem = entry:get_completion_item()
        --     local color = entryItem.documentation
        --
        --     if color and #color == 7 then
        --       local hl = 'cmp-square-' .. color:sub(2)
        --
        --       if #vim.api.nvim_get_hl(0, { name = hl }) == 0 then
        --         vim.api.nvim_set_hl(0, hl, { fg = color })
        --       end
        --
        --       item.menu = '■'
        --       item.menu_hl_group = hl
        --     end
        --
        --     return item
        --   end,
        -- },
      }
    end,
  },

  { -- Autoformat
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>f',
        function()
          require('conform').format { async = true, lsp_format = 'first' }
          vim.notify('Buffer formatted!', vim.log.levels.INFO)
        end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
    init = function()
      vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
      if vim.fn.executable 'prettierd' then
        vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
          group = vim.api.nvim_create_augroup('RestartPrettierd', { clear = true }),
          pattern = '*prettier*',
          callback = function()
            vim.fn.system 'prettierd restart'
          end,
        })
      end
    end,
    opts = function()
      local prettier = { 'prettierd', stop_after_first = true }
      return {
        notify_on_error = false,
        format_on_save = function(bufnr)
          -- Disable "format_on_save lsp_fallback" for languages that don't
          -- have a well standardized coding style. You can add additional
          -- languages here or re-enable it for the disabled ones.
          local disable_filetypes = { c = true, cpp = true }
          local lsp_format_opt
          if disable_filetypes[vim.bo[bufnr].filetype] then
            lsp_format_opt = 'never'
          else
            lsp_format_opt = 'first'
          end
          return {
            timeout_ms = 2000,
            lsp_format = lsp_format_opt,
          }
        end,
        formatters_by_ft = {
          lua = { 'stylua' },
          javascript = prettier,
          javascriptreact = prettier,
          typescript = prettier,
          typescriptreact = prettier,
          css = prettier,
          html = prettier,
          markdown = prettier,
          mdx = prettier,
          astro = { 'prettierd' },
          scss = prettier,
          yaml = prettier,
          json = prettier,
          jsonc = prettier,
        },
      }
    end,
  },
}

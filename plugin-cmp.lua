local cmp = require('cmp')

cmp.setup({
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body) -- For Luasnip users.
    end,
  },
  mapping = {
    ['<C-Space>'] = cmp.mapping.complete(), -- Manually trigger completion
    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Confirm the first suggestion
    ['<Tab>'] = cmp.mapping.select_next_item(), -- Navigate to next item
    ['<S-Tab>'] = cmp.mapping.select_prev_item(), -- Navigate to previous item
    ['<C-e>'] = cmp.mapping.abort(), -- Close the completion window
  },
  sources = cmp.config.sources({
    { name = 'nvim_lsp' }, -- LSP completions
    { name = 'buffer' },   -- Buffer completions
    { name = 'path' },     -- Path completions
    { name = 'luasnip' },  -- Snippet completions
  }),
  formatting = {
    fields = { 'abbr', 'kind', 'menu' },
    format = function(entry, item)
      item.menu = ({
        nvim_lsp = '[LSP]',
        buffer = '[Buffer]',
        path = '[Path]',
        luasnip = '[Snippet]',
      })[entry.source.name]
      return item
    end,
  },
})

-- Set up cmdline completion
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'path' },
    { name = 'cmdline' },
  },
})

local cmp = require("cmp")

-- Set up nvim-cmp (auto-complete)
---@diagnostic disable-next-line: redundant-parameter
cmp.setup({
  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body) -- For `luasnip` users.
    end,
  },
  mapping = {
    ---@diagnostic disable-next-line: undefined-field
    ["<C-Space>"] = cmp.mapping.complete(), -- Trigger completion manually
    ---@diagnostic disable-next-line: undefined-field
    ["<CR>"] = cmp.mapping(function(fallback)
      ---@diagnostic disable-next-line: undefined-field
      if cmp.visible() and cmp.get_selected_entry() then
        ---@diagnostic disable-next-line: undefined-field
        cmp.confirm({ select = false }) -- Only confirm if an item is explicitly selected
      else
        fallback() -- Otherwise, fallback to the default Enter behavior
      end
    end, { "i", "s" }), -- Supports insert and select mode
    ---@diagnostic disable-next-line: undefined-field
    ["<C-.>"] = cmp.mapping(cmp.mapping.select_next_item(), { "i", "c" }), -- Next item (i: insert, c: command)
    ---@diagnostic disable-next-line: undefined-field
    ["<C-,>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "c" }), -- Previous item
  },
  sources = {
    { name = "nvim_lsp" }, -- LSP completions (TypeScript, etc.)
    { name = "buffer" }, -- Completions from current buffer
    { name = "path" }, -- Path completions
    { name = "luasnip" }, -- Snippet completions
    { name = "npm", keyword_length = 3 }, -- NPM package completions
  },
  formatting = {
    format = require("tailwindcss-colorizer-cmp").formatter,
  },
})

return {
  "hrsh7th/nvim-cmp",
  dependencies = {
    "roobert/tailwindcss-colorizer-cmp.nvim",
  },
  config = function()
    local cmp = require("cmp")
    local tailwind_colorizer = require("tailwindcss-colorizer-cmp").formatter

    cmp.setup({
      snippet = {
        expand = function(args)
          require("luasnip").lsp_expand(args.body) -- For Luasnip users.
        end,
      },
      mapping = {
        ["<C-Space>"] = cmp.mapping.complete(), -- Manually trigger completion
        ["<CR>"] = cmp.mapping.confirm({ select = false }), -- Confirm the first suggestion
        ["<Down>"] = cmp.mapping.select_next_item(), -- Navigate to next item
        ["<Up>"] = cmp.mapping.select_prev_item(), -- Navigate to previous item
        ["<C-e>"] = cmp.mapping.abort(), -- Close the completion window
      },
      sources = cmp.config.sources({
        { name = "nvim_lsp" }, -- LSP completions
        -- { name = "buffer" }, -- Buffer completions
        { name = "path" }, -- Path completions
        { name = "luasnip" }, -- Snippet completions
      }),
      formatting = {
        fields = { "abbr", "kind", "menu" },
        expandable_indicator = true,
        format = function(entry, item)
          item = tailwind_colorizer(entry, item)
          item.menu = ({
            nvim_lsp = "[LSP]",
            buffer = "[Buffer]",
            path = "[Path]",
            luasnip = "[Snippet]",
          })[entry.source.name]
          return item
        end,
      },
    })

    -- Set up cmdline completion
    cmp.setup.cmdline(":", {
      mapping = cmp.mapping.preset.cmdline(),
      sources = {
        { name = "path" },
        { name = "cmdline" },
      },
    })
  end,
}

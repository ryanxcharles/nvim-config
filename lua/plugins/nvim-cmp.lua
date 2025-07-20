return {
  -- Autocompletion plugin
  -- { "hrsh7th/cmp-nvim-lsp" }, -- LSP source for nvim-cmp
  -- { "hrsh7th/cmp-buffer" }, -- Buffer source for nvim-cmp
  -- { "hrsh7th/cmp-path" }, -- Path source for nvim-cmp
  -- { "hrsh7th/cmp-cmdline" }, -- Command line completion
  -- { "saadparwaiz1/cmp_luasnip" }, -- Snippet completion
  -- { "L3MON4D3/LuaSnip" }, -- Snippet engine
  {
    "hrsh7th/nvim-cmp",
    opts = {
      sources = {
        { name = "nvim_lsp" }, -- LSP completions
        -- { name = "buffer" }, -- Buffer completions
        { name = "path" }, -- Path completions
        { name = "luasnip" }, -- Snippet completions
        { name = "emoji" }, -- Emoji completions
      },
    },
  },
}

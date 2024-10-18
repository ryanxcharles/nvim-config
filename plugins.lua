return {
  {
    'nvim-telescope/telescope.nvim',
    requires = { {'nvim-lua/plenary.nvim'} },
  },
  {
    'neovim/nvim-lspconfig',
    config = function()
      -- LSP configuration goes here
    end,
  },
  -- Add more plugins as needed
}


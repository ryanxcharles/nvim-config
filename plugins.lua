return {
  {
    'nvim-telescope/telescope.nvim',
    requires = { {'nvim-lua/plenary.nvim'} },
    config = function () 
      require("plugins-telescope")
    end,
  },
  {
    'neovim/nvim-lspconfig',
    config = function()
      -- LSP configuration goes here
    end,
  },

  -- LSP for TypeScript, etc.
  -- use("neovim/nvim-lspconfig")
  {
    'neovim/nvim-lspconfig'
  }
  -- Add more plugins as needed
}

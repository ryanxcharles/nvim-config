return {
  -- Telescope for finding files and grepping
  {
    'nvim-telescope/telescope.nvim',
    requires = { {'nvim-lua/plenary.nvim'} },
    config = function () 
      require("plugins-telescope")
    end,
  },

  -- LSP: For all language servers
  {
    'neovim/nvim-lspconfig',
    config = function()
      -- LSP configuration goes here
    end,
  },

  -- GitHub Copilot
  {
    "github/copilot.vim", -- GitHub Copilot
    config = function()
      -- Optional Copilot setup if needed
      vim.cmd("Copilot setup")
    end,
  },
  {
    "zbirenbaum/copilot-cmp", -- Copilot completion source for cmp
    dependencies = { "github/copilot.vim" }, -- Ensure it loads after copilot.vim
    config = function()
      require("copilot_cmp").setup()
    end,
  },
}

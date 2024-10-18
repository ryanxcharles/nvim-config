return {
  -- Telescope for finding files and grepping
  {
    "nvim-telescope/telescope.nvim",
    requires = { { "nvim-lua/plenary.nvim" } },
    config = function()
      require("plugins-telescope")
    end,
  },

  -- LSP: For all language servers
  {
    "neovim/nvim-lspconfig",
    config = function()
      -- LSP configuration goes here
    end,
  },

  { "hrsh7th/nvim-cmp" }, -- Autocompletion plugin
  { "hrsh7th/cmp-nvim-lsp" }, -- LSP source for nvim-cmp
  { "hrsh7th/cmp-buffer" }, -- Buffer source for nvim-cmp
  { "hrsh7th/cmp-path" }, -- Path source for nvim-cmp
  { "hrsh7th/cmp-cmdline" }, -- Command line completion
  { "saadparwaiz1/cmp_luasnip" }, -- Snippet completion
  { "L3MON4D3/LuaSnip" }, -- Snippet engine

  -- GitHub Copilot
  {
    "github/copilot.vim", -- GitHub Copilot
    config = function()
      -- Optional Copilot setup if needed
      -- vim.cmd("Copilot setup")
    end,
  },
  {
    "zbirenbaum/copilot-cmp", -- Copilot completion source for cmp
    dependencies = { "github/copilot.vim" }, -- Ensure it loads after copilot.vim
    config = function()
      require("copilot_cmp").setup()
    end,
  },

  -- Treesitter for syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    run = ":TSUpdate",
    config = function()
      require("plugins-treesitter")
    end,
  },

  -- Code formatting
  {
    "mhartington/formatter.nvim",
    config = function()
      require("plugins-formatter")
    end,
  },

  -- Colorizer for HTML/CSS
  {
    "NvChad/nvim-colorizer.lua",
    config = function()
      require("plugins-colorizer")
    end,
  },

  -- Rainbow delimiters <{[(
  {
    "HiPhish/rainbow-delimiters.nvim",
    config = function()
      require("plugins-rainbow")
    end,
  },

  -- Lualine for status line
  {
    "nvim-lualine/lualine.nvim",
    config = function()
      require("plugins-lualine")
    end,
  },

  -- Git integration
  {
    "tpope/vim-fugitive",
  },

  -- Markdown preview
  {
    "preservim/vim-markdown",
    dependencies = { "godlygeek/tabular" },
  },

  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v2.x",
    dependencies = {
      "nvim-lua/plenary.nvim", -- Required dependency
      "nvim-tree/nvim-web-devicons", -- Optional dependency for file icons
      "MunifTanjim/nui.nvim", -- Required dependency for UI components
    },
  },

  -- Codewindow setup (minimap)
  {
    "gorbit99/codewindow.nvim",
    config = function()
      require("plugins-codewindow")
    end,
  },

  -- Dressing - better input boxes
  {
    "stevearc/dressing.nvim",
  },

  -- Better comment/uncomment
  {
    "tpope/vim-commentary",
  },

  -- surround.vim - Surround text objects
  {
    "tpope/vim-surround",
  },

  {
    "luckasRanarison/tailwind-tools.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-telescope/telescope.nvim",
      "neovim/nvim-lspconfig",
    },
    run = ":UpdateRemotePlugins",
  },

  {
    "roobert/tailwindcss-colorizer-cmp.nvim",
    config = function ()
      require("plugins-tailwindcss-colorizer")
    end,
  },

  -- alpha-nvim greeter (splash screen)
  {
    "goolord/alpha-nvim",
    dependencies = {
      "echasnovski/mini.icons"
    },
    config = function()
      require("alpha").setup(require("alpha.themes.startify").opts)
    end,
  },

  {
    "jose-elias-alvarez/null-ls.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
  },

  {
    "simrat39/rust-tools.nvim",
    dependencies = { "neovim/nvim-lspconfig" },
    config = function()
      require("plugin-rust-tools")
    end,
  },

  {
    "saecki/crates.nvim",
    dependencies = {
      "jose-elias-alvarez/null-ls.nvim",
    },
    config = function()
      require("plugin-crates")
    end,
  },
}

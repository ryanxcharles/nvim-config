return {
  -- Telescope for finding files and grepping
  {
    "nvim-telescope/telescope.nvim",
    requires = { { "nvim-lua/plenary.nvim" } },
    config = function()
      require("plugin-telescope")
    end,
  },

  -- LSP: For all language servers
  {
    "neovim/nvim-lspconfig",
    config = function()
      -- LSP configuration goes here
      require("plugin-lsp")
    end,
  },

  -- Tailwind CSS colorizer
  {
    "roobert/tailwindcss-colorizer-cmp.nvim",
    config = function()
      require("tailwindcss-colorizer-cmp").setup({
        color_square_width = 2,
      })
    end,
  },

  {
    "hrsh7th/nvim-cmp",
    -- dependencies = {
    --   "roobert/tailwindcss-colorizer-cmp.nvim",
    -- },
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
          ["<CR>"] = cmp.mapping.confirm({ select = true }), -- Confirm the first suggestion
          ["<Down>"] = cmp.mapping.select_next_item(), -- Navigate to next item
          ["<Up>"] = cmp.mapping.select_prev_item(), -- Navigate to previous item
          ["<C-e>"] = cmp.mapping.abort(), -- Close the completion window
        },
        sources = cmp.config.sources({
          { name = "nvim_lsp" }, -- LSP completions
          { name = "buffer" }, -- Buffer completions
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
  },

  -- Autocompletion plugin
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
      -- require("plugin-copilot")
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
      require("plugin-treesitter")
    end,
  },

  -- Code formatting
  {
    "mhartington/formatter.nvim",
    config = function()
      require("plugin-formatter")
    end,
  },

  -- Colorizer for HTML/CSS
  {
    "NvChad/nvim-colorizer.lua",
    config = function()
      require("plugin-colorizer")
    end,
  },

  -- Rainbow delimiters <{[(
  {
    "HiPhish/rainbow-delimiters.nvim",
    config = function()
      require("plugin-rainbow")
    end,
  },

  -- Lualine for status line
  {
    "nvim-lualine/lualine.nvim",
    config = function()
      require("plugin-lualine")
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
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim", -- Required dependency
      "nvim-tree/nvim-web-devicons", -- Optional dependency for file icons
      "MunifTanjim/nui.nvim", -- Required dependency for UI components
    },
    config = function()
      require("plugin-neo-tree")
    end,
  },

  -- Codewindow setup (minimap)
  {
    "gorbit99/codewindow.nvim",
    config = function()
      require("plugin-codewindow")
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

  -- tailwind colors and other features like classNames
  -- {
  --   "luckasRanarison/tailwind-tools.nvim",
  --   name = "tailwind-tools",
  --   dependencies = {
  --     "nvim-treesitter/nvim-treesitter",
  --     "nvim-telescope/telescope.nvim",
  --     "neovim/nvim-lspconfig",
  --   },
  --   run = ":UpdateRemotePlugins",
  --   opts = {},
  -- },

  -- alpha-nvim greeter (splash screen)
  {
    "goolord/alpha-nvim",
    dependencies = {
      "echasnovski/mini.icons",
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

  {
    "folke/lazydev.nvim",
    dependencies = {
      "folke/lazy.nvim",
    },
    config = function()
      require("lazydev").setup()
    end,
  },

  -- metadata & type support for luvit (uv), an IO library for Lua
  {
    "Bilal2453/luvit-meta",
  },

  -- save and re-load session
  {
    "stevearc/resession.nvim",
    opts = {},
    config = function()
      require("resession").setup({})
    end,
  },

  -- colors: catppuccin
  {
    "catppuccin/nvim",
    name = "catppuccin",
    config = function()
      require("catppuccin").setup({
        flavour = "mocha", -- options: latte, frappe, macchiato, mocha
        -- other configurations if needed
      })
      vim.cmd("colorscheme catppuccin")
    end,
  },
}

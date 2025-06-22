-- # Ryan X. Charles NVim Configuration
--
-- The following tools must be installed to use this configuration:
-- - nvim v0.10.1+ (Neovim)
-- - git v2.33.0+ (for git integration)
-- - ripgrip v14.1.1 (for Telescope)
-- - stylua v0.20.0 (for Lua formatting)
-- - biome v1.9.2 (for TypeScript formatting)
-- - deno v2.0.0 (for Deno TypeScript LSP)
-- - prettier (for Markdown formatting)
-- - Nerdfonts (for icons)
-- - tailwindcss-language-server (for Tailwind CSS completions and colors)
-- - typescript-language-server (for TypeScript completions and diagnostics)
-- - rust/cargo (for Rust tools)
-- - lua-language-server (for Lua completions and diagnostics)
-- - wgsl-analyzer (for WebGPU Shading Language diagnostics)
-- - ruff (for Python diagnostics)

-- TODO:
-- [ ] replace formatter with null-ls
-- [ ] Add Gitsigns (lewis6991/gitsigns.nvim)
-- [ ] Add markdown-preview.nvim (iamcco/markdown-preview.nvim)
-- [ ] replace rainbow-delimiters with nvim-ts-rainbow (p00f/nvim-ts-rainbow)

-- ~/.config/nvim/init.lua
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local original_path = package.path
package.path = package.path .. ";" .. vim.fn.stdpath("config") .. "/?.lua"

require("lazy").setup({
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

  -- Copilot completion source for nvim-cmp
  {
    "zbirenbaum/copilot-cmp", -- Copilot completion source for cmp
    dependencies = { "github/copilot.vim" }, -- Ensure it loads after copilot.vim
    config = function()
      require("copilot_cmp").setup()
    end,
  },

  -- Copilot Chat
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      { "github/copilot.vim" }, -- or zbirenbaum/copilot.lua
      { "nvim-lua/plenary.nvim", branch = "master" }, -- for curl, log and async functions
    },
    build = "make tiktoken", -- Only on MacOS or Linux
    opts = {
      -- See Configuration section for options
    },
    -- See Commands section for default commands if you want to lazy load on them
  },

  -- nushell
  {
    "LhKipp/nvim-nu",
    config = function()
      require("nu").setup()
    end,
  },

  -- Treesitter for syntax highlighting
  -- {
  --   "nvim-treesitter/nvim-treesitter",
  --   dependencies = {
  --     "LhKipp/nvim-nu",
  --   },
  --   run = ":TSUpdate",
  -- },

  -- Treesitter for syntax highlighting and text-objects for selecting markdown code blocks
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    dependencies = { "nvim-treesitter/nvim-treesitter", "LhKipp/nvim-nu" },
    run = ":TSUpdate",
    config = function()
      ---@diagnostic disable-next-line: missing-fields
      require("nvim-treesitter.configs").setup({
        -- Install parsers for various languages
        ensure_installed = {
          "css",
          "html",
          "javascript",
          "jsdoc",
          "json",
          "jsonc",
          "lua",
          "markdown",
          "markdown_inline",
          "nu",
          "python",
          "rust",
          "toml",
          "tsx",
          "typescript",
          "wgsl",
          "yaml",
        }, -- Add more languages as needed

        -- Enable Treesitter-based syntax highlighting
        highlight = {
          enable = true, -- Enable Treesitter highlighting
          additional_vim_regex_highlighting = false, -- Disable Vim's regex-based highlighting
        },

        -- You can enable more Treesitter features as needed (optional)
        indent = { enable = false }, -- Enable Treesitter-based indentation (optional)

        -- Folding
        fold = { enable = true }, -- Enable Treesitter-based folding (optional)

        -- Required for nvim-treesitter-textobjects
        textobjects = {
          select = {
            enable = true,
            lookahead = true, -- Automatically jump forward to textobj if cursor is outside
            keymaps = {
              -- Define a custom text object for markdown fenced code blocks
              ["ic"] = {
                query = "@codeblock.inner",
                desc = "Select inside markdown code block",
              },
              ["ac"] = {
                query = "@codeblock.outer",
                desc = "Select around markdown code block",
              },
              ["if"] = {
                query = "@function.inner",
                desc = "Select inside function (TypeScript, etc.)",
              },
              ["af"] = {
                query = "@function.outer",
                desc = "Select around function (TypeScript, etc.)",
              },
              ["ik"] = {
                query = "@class.inner",
                desc = "Select inside class (TypeScript, etc.)",
              },
              ["ak"] = {
                query = "@class.outer",
                desc = "Select around class (TypeScript, etc.)",
              },
            },
            -- Optionally, configure selection modes or other settings
            selection_modes = {
              ["@codeblock.inner"] = "V", -- Use linewise visual mode for inner selection
              ["@codeblock.outer"] = "V", -- Use linewise visual mode for outer selection
              ["@function.inner"] = "V",
              ["@function.outer"] = "V",
              ["@class.inner"] = "V",
              ["@class.outer"] = "V",
            },
          },
          move = {
            enable = true,
            set_jumps = true, -- Add to jump list for navigation history
            goto_next_start = {
              ["]c"] = {
                query = "@codeblock.outer",
                desc = "Next code block start",
              },
              ["]f"] = {
                query = "@function.outer",
                desc = "Next function start",
              },
              ["]k"] = { query = "@class.outer", desc = "Next class start" },
            },
            goto_next_end = {
              ["]C"] = {
                query = "@codeblock.outer",
                desc = "Next code block end",
              },
            },
            goto_previous_start = {
              ["[c"] = {
                query = "@codeblock.outer",
                desc = "Previous code block start",
              },
              ["[f"] = {
                query = "@function.outer",
                desc = "Previous function start",
              },
              ["[k"] = { query = "@class.outer", desc = "Previous class start" },
            },
            goto_previous_end = {
              ["[C"] = {
                query = "@codeblock.outer",
                desc = "Previous code block end",
              },
            },
          },
        },
      })

      -- Define the custom Tree-sitter queries for markdown code blocks
      vim.treesitter.query.set(
        "markdown",
        "textobjects",
        [[
      (fenced_code_block
        (code_fence_content) @codeblock.inner
      ) @codeblock.outer
    ]]
      )
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
    "nvimtools/none-ls.nvim",
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
      "nvimtools/none-ls.nvim",
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

  -- watch for changes in files and reload them
  {
    -- "djoshea/vim-autoread",
    -- dir = "~/dev/vim-autoread",
    "ryanxcharles/vim-autoclose",
  },

  -- ChatVim: public install
  -- {
  --   "chatvim/chatvim.nvim",
  --   build = "npm install",
  --   config = function()
  --     require("chatvim")
  --   end,
  -- },

  -- ChatVim: local install
  {
    dir = "~/dev/chatvim.nvim",
    name = "chatvim.nvim",
    config = function()
      require("chatvim")
    end,
  },
})
-- local config_path = vim.fn.stdpath("config") .. "/lua/"
require("globals")
require("keybindings")
require("colors")

package.path = original_path

return {
  "nvim-treesitter/nvim-treesitter-textobjects",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
  },
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
        -- "zsh",
        "bash",
        "latex",
        "bibtex",
      }, -- Add more languages as needed

      -- Enable Treesitter-based syntax highlighting
      highlight = {
        enable = true, -- Enable Treesitter highlighting
        additional_vim_regex_highlighting = { "markdown" },
        -- additional_vim_regex_highlighting = false,
      },

      -- You can enable more Treesitter features as needed (optional)
      indent = { enable = false }, -- Enable Treesitter-based indentation (optional)

      -- Folding
      fold = { enable = true }, -- Enable Treesitter-based folding (optional)

      -- Required for nvim-treesitter-textobjects
      textobjects = {
        -- select = {
        --   enable = true,
        --   lookahead = true, -- Automatically jump forward to textobj if cursor is outside
        --   keymaps = {
        --     -- Define a custom text object for markdown fenced code blocks
        --     ["ix"] = {
        --       query = "@codeblock.inner",
        --       desc = "Select inside markdown code block",
        --     },
        --     ["ax"] = {
        --       query = "@codeblock.outer",
        --       desc = "Select around markdown code block",
        --     },
        --     -- ["if"] = {
        --     --   query = "@function.inner",
        --     --   desc = "Select inside function (TypeScript, etc.)",
        --     -- },
        --     -- ["af"] = {
        --     --   query = "@function.outer",
        --     --   desc = "Select around function (TypeScript, etc.)",
        --     -- },
        --     -- ["ik"] = {
        --     --   query = "@class.inner",
        --     --   desc = "Select inside class (TypeScript, etc.)",
        --     -- },
        --     -- ["ak"] = {
        --     --   query = "@class.outer",
        --     --   desc = "Select around class (TypeScript, etc.)",
        --     -- },
        --   },
        --   -- Optionally, configure selection modes or other settings
        --   selection_modes = {
        --     ["@codeblock.inner"] = "V", -- Use linewise visual mode for inner selection
        --     ["@codeblock.outer"] = "V", -- Use linewise visual mode for outer selection
        --     ["@function.inner"] = "V",
        --     ["@function.outer"] = "V",
        --     ["@class.inner"] = "V",
        --     ["@class.outer"] = "V",
        --   },
        -- },
        move = {
          enable = true,
          set_jumps = true, -- Add to jump list for navigation history
          -- goto_next_start = {
          --   ["]x"] = {
          --     query = "@codeblock.outer",
          --     desc = "Next code block start",
          --   },
          --   -- ["]f"] = {
          --   --   query = "@function.outer",
          --   --   desc = "Next function start",
          --   -- },
          --   -- ["]k"] = { query = "@class.outer", desc = "Next class start" },
          -- },
          -- goto_next_end = {
          --   ["]X"] = {
          --     query = "@codeblock.outer",
          --     desc = "Next code block end",
          --   },
          -- },
          -- goto_previous_start = {
          --   ["[x"] = {
          --     query = "@codeblock.outer",
          --     desc = "Previous code block start",
          --   },
          --   -- ["[f"] = {
          --   --   query = "@function.outer",
          --   --   desc = "Previous function start",
          --   -- },
          --   -- ["[k"] = { query = "@class.outer", desc = "Previous class start" },
          -- },
          -- goto_previous_end = {
          --   ["[X"] = {
          --     query = "@codeblock.outer",
          --     desc = "Previous code block end",
          --   },
          -- },
        },
      },
    })

    -- -- Define the custom Tree-sitter queries for markdown code blocks
    -- vim.treesitter.query.set(
    --   "markdown",
    --   "textobjects",
    --   [[
    --   (fenced_code_block
    --     (code_fence_content) @codeblock.inner
    --   ) @codeblock.outer
    -- ]]
    -- )

    -- Enable Treesitter folding globally
    vim.opt.foldmethod = "expr"
    vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
    vim.opt.foldenable = true
    vim.opt.foldlevelstart = 99 -- Start with all folds open

    -- Alias zsh to bash for Markdown code blocks
    vim.treesitter.language.register("bash", "zsh")
  end,
}

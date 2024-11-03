-- Accurate syntax highlighting for TypeScript and other languages
---@diagnostic disable-next-line: missing-fields
require("nvim-treesitter.configs").setup({
  -- Install parsers for various languages
  ensure_installed = {
    "javascript",
    "typescript",
    "tsx",
    "json",
    "jsonc",
    "jsdoc",
    "html",
    "css",
    "rust",
    "markdown",
    "markdown_inline",
    "toml",
    "wgsl",
    "nu",
  }, -- Add more languages as needed

  -- Enable Treesitter-based syntax highlighting
  highlight = {
    enable = true, -- Enable Treesitter highlighting
    additional_vim_regex_highlighting = false, -- Disable Vim's regex-based highlighting
  },

  -- You can enable more Treesitter features as needed (optional)
  indent = { enable = true }, -- Enable Treesitter-based indentation (optional)

  -- Folding
  fold = { enable = true }, -- Enable Treesitter-based folding (optional)
})

-- Use Treesitter for folding
-- vim.opt.foldmethod = "expr"
-- vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
-- vim.opt.foldenable = false -- Disable folding by default

return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    indent = {
      enable = true,
      -- Disable for problematic languages
      disable = { "typescript", "typescriptreact" },
    },
  },
}

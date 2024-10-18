-- rust: integration with crates.nvim for managing dependencies
require("crates").setup({
  null_ls = {
    enabled = true, -- Enable null-ls integration (optional)
    name = "crates.nvim",
  },
})

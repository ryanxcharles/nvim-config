local opts = { noremap = true, silent = true }

-- rust: integration with crates.nvim for managing dependencies
require("crates").setup({
  null_ls = {
    enabled = true, -- Enable null-ls integration (optional)
    name = "crates.nvim",
  },
})

-- Optional keybinding to update dependencies with `crates.nvim`
vim.api.nvim_set_keymap(
  "n",
  "<Leader>cu",
  ":lua require('crates').update_crate()<CR>",
  opts
)

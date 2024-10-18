local rust_tools = require("rust-tools")

local opts = { noremap = true, silent = true }

-- rust: Rust tools setup with rust-analyzer
rust_tools.setup({
  server = {
    on_attach = function(client, bufnr)
      -- Keybindings for LSP features in Rust files
      vim.api.nvim_buf_set_keymap(
        bufnr,
        "n",
        "gd",
        "<cmd>lua vim.lsp.buf.definition()<CR>",
        opts
      )
      vim.api.nvim_buf_set_keymap(
        bufnr,
        "n",
        "K",
        "<cmd>lua vim.lsp.buf.hover()<CR>",
        opts
      )
      vim.api.nvim_buf_set_keymap(
        bufnr,
        "n",
        "<Leader>ca",
        "<cmd>lua vim.lsp.buf.code_action()<CR>",
        opts
      )
      vim.api.nvim_buf_set_keymap(
        bufnr,
        "n",
        "<Leader>rn",
        "<cmd>lua vim.lsp.buf.rename()<CR>",
        opts
      )
    end,
    settings = {
      ["rust-analyzer"] = {
        cargo = { allFeatures = true },
        checkOnSave = { command = "clippy" }, -- Run clippy on save
      },
    },
  },
})

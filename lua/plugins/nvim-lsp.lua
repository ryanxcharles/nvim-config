return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      rescriptls = {},
      tailwindcss = {
        filetypes = {
          "html",
          "css",
          "javascript",
          "typescript",
          "javascriptreact",
          "typescriptreact",
          "lua",
          "tsx",
          "nu",
        },
      },
    },
  },
}

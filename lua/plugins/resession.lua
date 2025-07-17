return {
  {
    "stevearc/resession.nvim",
    opts = {},
    config = function()
      require("resession").setup({})
      -- Keybindings for resession
      local opts = { noremap = true, silent = true }
      vim.api.nvim_set_keymap("n", "<Leader>ss", ":lua require('resession').save()<CR>", opts)
      vim.api.nvim_set_keymap("n", "<Leader>sl", ":lua require('resession').load()<CR>", opts)
      vim.api.nvim_set_keymap("n", "<Leader>sd", ":lua require('resession').delete()<CR>", opts)
      vim.api.nvim_set_keymap("n", "<Leader>sc", ":lua require('resession').autosave_toggle()<CR>", opts)
    end,
  },
}

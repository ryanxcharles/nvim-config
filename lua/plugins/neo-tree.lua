return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim", -- Required dependency
    "nvim-tree/nvim-web-devicons", -- Optional dependency for file icons
    "MunifTanjim/nui.nvim", -- Required dependency for UI components
  },
  config = function()
    -- Neo-tree setup (neotree)
    require("neo-tree").setup({
      close_if_last_window = true, -- Closes Neo-tree if it's the last open window
      popup_border_style = "rounded", -- Rounded border for popups
      enable_git_status = true, -- Show git status icons
      enable_diagnostics = true, -- Show LSP diagnostics in the file tree
      filesystem = {
        -- follow_current_file = true, -- Automatically focus on the current file
        use_libuv_file_watcher = true, -- Automatically refresh the tree when files change
        filtered_items = {
          hide_dotfiles = false,
        },
      },
      buffers = {
        -- follow_current_file = true, -- Automatically focus on the current buffer
      },
      git_status = {
        window = {
          position = "float", -- Open a floating window for git status
        },
      },
    })
    -- Neo-tree keybindings
    local opts = { noremap = true, silent = true }
    vim.api.nvim_set_keymap("n", "<Leader>rb", ":Neotree buffers position=float<CR>", opts)
    vim.api.nvim_set_keymap("n", "<Leader>rf", ":Neotree filesystem position=float<CR>", opts)
    vim.api.nvim_set_keymap("n", "<Leader>rr", ":Neotree reveal position=float<CR>", opts)
    vim.api.nvim_set_keymap("n", "<Leader>e", ":Neotree filesystem position=left<CR>", opts)
    vim.api.nvim_set_keymap("n", "<Leader>E", ":Neotree filesystem position=left<CR>", opts)
    vim.api.nvim_set_keymap("n", "<Leader>fe", ":Neotree filesystem position=left<CR>", opts)
    vim.api.nvim_set_keymap("n", "<Leader>fE", ":Neotree filesystem position=left<CR>", opts)
  end,
}

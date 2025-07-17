return {
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({
        -- change keymaps so as to not conflict with flash.nvim
        keymaps = {
          -- insert = "<C-g>s",
          -- insert_line = "<C-g>S",
          -- normal = "ys", -- or "gs" to avoid conflicts
          -- normal_cur = "yss",
          -- normal_line = "yS",
          -- normal_cur_line = "ySS",
          visual = "gS", -- Change from 'S' to 'gS' in visual mode
          visual_line = "gSS",
          -- delete = "ds",
          -- change = "cs",
          -- change_line = "cS",
        },
      })
    end,
  },
}

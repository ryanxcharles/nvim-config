return {
  {
    "folke/flash.nvim",
    -- lazy = false, -- force this to load before vim-surround
    -- -- enabled = false,
    -- event = "VeryLazy",
    -- vscode = true,
    -- ---@type Flash.Config
    -- opts = {},
    -- -- stylua: ignore
    -- keys = {
    --   { "f", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
    --   { "F", mode = { "n", "o", "x" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
    --   { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
    --   { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
    --   { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
    -- },
  },
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({
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

-- telescope.lua
require("telescope").setup({
  defaults = {
    file_ignore_patterns = { "node_modules" }, -- Exclude node_modules from typeahead matching
    vimgrep_arguments = {
      "rg", -- Ripgrep binary
      "--color=never",
      "--no-heading",
      "--with-filename",
      "--line-number",
      "--column",
      "--smart-case",
      "--hidden", -- Search hidden files, because we use .server and .client
      "--glob",
      "!**/.git/**", -- Exclude the .git folder
    },
    -- Other default settings
  },
})

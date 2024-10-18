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

local opts = { noremap = true, silent = true }

-- Custom keybindings for Telescope
vim.api.nvim_set_keymap('n', '<Leader>ff', ":Telescope find_files<CR>", opts)
vim.api.nvim_set_keymap('n', '<Leader>fg', ":Telescope live_grep<CR>", opts)

-- Set Telescope background color to #0a0a0a
vim.api.nvim_set_hl(0, "TelescopeNormal", { bg = "#0a0a0a" }) -- Normal background
-- vim.api.nvim_set_hl(0, "TelescopeBorder", { bg = "#0a0a0a", fg = "#0a0a0a" })  -- Border color (make it blend)
-- vim.api.nvim_set_hl(0, "TelescopePromptNormal", { bg = "#0a0a0a" })  -- Prompt background
-- vim.api.nvim_set_hl(0, "TelescopeResultsNormal", { bg = "#0a0a0a" }) -- Results background
-- vim.api.nvim_set_hl(0, "TelescopePreviewNormal", { bg = "#0a0a0a" }) -- Preview background

-- Key binding to use Telescope to search files, including respecting .gitignore
vim.api.nvim_set_keymap(
  "n",
  "<Leader>e",
  ":lua require('telescope.builtin').git_files({ show_untracked = true })<CR>",
  opts
)

-- Telscope search inside files with ripgrep (rg)
vim.api.nvim_set_keymap("n", "<Leader>fg", ":Telescope live_grep<CR>", opts)

-- LSP integration with Telescope for TypeScript and other languages
-- Space + fs: Search document symbols (like variables, functions, etc.).
vim.api.nvim_set_keymap(
  "n",
  "<Leader>fs",
  "<cmd>Telescope lsp_document_symbols<CR>",
  opts
)
-- Space + fr: Find all references to a symbol.
vim.api.nvim_set_keymap(
  "n",
  "<Leader>fr",
  "<cmd>Telescope lsp_references<CR>",
  opts
)
-- Space + fd: Search through diagnostics (errors, warnings).
vim.api.nvim_set_keymap(
  "n",
  "<Leader>fd",
  "<cmd>Telescope diagnostics<CR>",
  opts
)
-- Show all diagnostics on the current line in a floating window
vim.api.nvim_set_keymap(
  "n",
  "<Leader>ds",
  "<cmd>lua vim.diagnostic.open_float(nil, { focusable = false })<CR>",
  opts
)
-- Go to the next diagnostic (error, warning, etc.)
vim.api.nvim_set_keymap(
  "n",
  "<Leader>dn",
  ":lua vim.diagnostic.goto_next()<CR>",
  opts
)
-- Go to the previous diagnostic (error, warning, etc.)
vim.api.nvim_set_keymap(
  "n",
  "<Leader>dp",
  ":lua vim.diagnostic.goto_prev()<CR>",
  opts
)

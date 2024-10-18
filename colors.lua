-- Enable 24-bit RGB color in the terminal
vim.opt.termguicolors = true

-- TODO: test todo highlighting
-- Define a highlight group for TODO comments
vim.api.nvim_command("highlight TodoComment guifg=#FA8603 gui=bold") -- Orange color with bold
-- Automatically highlight TODO comments when entering a buffer
vim.api.nvim_create_autocmd({ "BufEnter", "BufReadPost" }, {
  group = vim.api.nvim_create_augroup("TodoHighlight", { clear = true }),
  pattern = "*",
  callback = function()
    vim.fn.matchadd("TodoComment", "TODO:")
  end,
})

-- TODO: This doesn't work - is this fixable?
-- Custom cursor color
vim.api.nvim_set_hl(0, "Cursor", { bg = "#FA8603", fg = "#000000" })

-- Custom color for search highlighting
vim.api.nvim_set_hl(0, "Search", { bg = "#87af5f", fg = "#000000" })
-- Custom color for visual mode
vim.api.nvim_set_hl(0, "Visual", { bg = "#5f87af", fg = "#ffffff" })
-- Custom color for incremental search
vim.api.nvim_set_hl(0, "IncSearch", { bg = "#875fff", fg = "#ffffff" })

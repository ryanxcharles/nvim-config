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

-- Set background colors for active and inactive windows
-- Define the colors for active and inactive windows
vim.api.nvim_set_hl(0, "ActiveWindow", { bg = "#0f0f16" }) -- Active window background color
-- vim.api.nvim_set_hl(0, "InactiveWindow", { bg = "#14161b" }) -- Inactive window background color
-- vim.api.nvim_set_hl(0, "InactiveWindow", { bg = "NONE" }) -- Inactive window background color

-- Set Neovim background to transparent
vim.api.nvim_set_hl(0, "Normal", { bg = "#16161f" })
vim.api.nvim_set_hl(0, "NormalNC", { bg = "#16161f" })

-- Autocommand for entering a window (active)
vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
  callback = function()
    vim.wo.winhighlight = "Normal:ActiveWindow" -- Set active window background
  end,
})

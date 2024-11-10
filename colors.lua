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
-- vim.api.nvim_set_hl(0, "ActiveWindow", { bg = "#0f0f16" }) -- Active window background color
-- vim.api.nvim_set_hl(0, "InactiveWindow", { bg = "#14161b" }) -- Inactive window background color
-- vim.api.nvim_set_hl(0, "InactiveWindow", { bg = "NONE" }) -- Inactive window background color

-- Set Neovim background to transparent
-- vim.api.nvim_set_hl(0, "Normal", { bg = "#04060b" })
-- vim.api.nvim_set_hl(0, "NormalNC", { bg = "#04060b" })
vim.api.nvim_set_hl(0, "Normal", { bg = "NONE" })
vim.api.nvim_set_hl(0, "NormalNC", { bg = "NONE" })

-- Autocommand for entering a window (active)
vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
  callback = function()
    vim.wo.winhighlight = "Normal:ActiveWindow" -- Set active window background
  end,
})

-- b = { fg = "#ffffff", bg = "#0087ff" },
-- Define custom highlight groups for tabs with a bright blue background
vim.api.nvim_set_hl(
  0,
  "TabLineSel",
  { fg = "#ffffff", bg = "#5f87af", bold = false }
) -- Selected tab
vim.api.nvim_set_hl(
  0,
  "TabLine",
  -- { fg = "#ffffff", bg = "#14161b", bold = false }
  { fg = "#ffffff", bg = "NONE", bold = false }
) -- Non-selected tabs

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

-- moderately bright cursor column on the highlighted window only
vim.api.nvim_set_hl(0, "CursorLine", { bg = "#000000" }) -- Set this to your preferred color
-- vim.api.nvim_set_hl(0, "CursorColumn", { bg = "#000000" }) -- Set this to your preferred color
vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
  pattern = "*",
  callback = function()
    vim.api.nvim_set_hl(0, "CursorLine", { bg = "#000000" }) -- Set this to your preferred color
    -- vim.api.nvim_set_hl(0, "CursorColumn", { bg = "#000000" }) -- Set this to your preferred color
    vim.wo.cursorline = true -- Enable cursor column in the active window
    -- vim.wo.cursorcolumn = true -- Enable cursor column in the active window
  end,
})
vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
  pattern = "*",
  callback = function()
    vim.wo.cursorline = false -- Disable cursor column in inactive windows
    -- vim.wo.cursorcolumn = false -- Disable cursor column in inactive windows
  end,
})

-- Set background colors for active and inactive windows
-- Define the colors for active and inactive windows
vim.api.nvim_set_hl(0, "ActiveWindow", { bg = "#08090c" }) -- Active window background color
-- vim.api.nvim_set_hl(0, "InactiveWindow", { bg = "#14161b" }) -- Inactive window background color
-- vim.api.nvim_set_hl(0, "InactiveWindow", { bg = "NONE" }) -- Inactive window background color

-- Set Neovim background to transparent
vim.api.nvim_set_hl(0, "Normal", { bg = "NONE" })
vim.api.nvim_set_hl(0, "NormalNC", { bg = "NONE" })

-- Autocommand for entering a window (active)
vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
  callback = function()
    vim.wo.winhighlight = "Normal:ActiveWindow" -- Set active window background
  end,
})

-- Set Telescope background color to #0a0a0a
vim.api.nvim_set_hl(0, "TelescopeNormal", { bg = "#08090c" }) -- Normal background
-- vim.api.nvim_set_hl(0, "TelescopeBorder", { bg = "#0a0a0a", fg = "#0a0a0a" })  -- Border color (make it blend)
-- vim.api.nvim_set_hl(0, "TelescopePromptNormal", { bg = "#0a0a0a" })  -- Prompt background
-- vim.api.nvim_set_hl(0, "TelescopeResultsNormal", { bg = "#0a0a0a" }) -- Results background
-- vim.api.nvim_set_hl(0, "TelescopePreviewNormal", { bg = "#0a0a0a" }) -- Preview background


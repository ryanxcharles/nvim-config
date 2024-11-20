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

vim.opt.fillchars = {
  horiz = '━',
  horizup = '┻',
  horizdown = '┳',
  vert = '┃',
  vertleft = '┫',
  vertright = '┣',
  verthoriz = '╋',
}

-- Make active window separator more visible
vim.api.nvim_set_hl(0, 'WinSeparatorNC', { fg = '#1E1E2E' })  -- inactive window separator
vim.api.nvim_set_hl(0, 'WinSeparator', { fg = '#000000' }) -- active window separator
vim.opt.winhl = 'WinSeparator:WinSeparator'
vim.api.nvim_set_hl(0, 'NormalNC', { bg = '#1E1E2E' })          -- active window background
vim.api.nvim_set_hl(0, 'Normal', { bg = '#161626' })        -- inactive window background

-- Enable window borders globally
vim.opt.number = true  -- This helps with left border visibility
vim.opt.relativenumber = true  -- Optional
vim.opt.signcolumn = "yes"    -- This helps ensure left border space
vim.opt.foldcolumn = "1"      -- This can help with left border too

-- Create autocmd for window focus
vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter", "WinLeave", "BufLeave" }, {
  callback = function()
    local wins = vim.api.nvim_list_wins()
    for _, w in ipairs(wins) do
      if w == vim.api.nvim_get_current_win() then
        -- Current window gets highlighted border and background
        vim.wo[w].winhighlight = 'WinSeparator:WinSeparator,Normal:Normal'
      else
        -- Other windows get dim border and background
        vim.wo[w].winhighlight = 'WinSeparator:WinSeparatorNC,Normal:NormalNC'
      end
    end
  end,
})

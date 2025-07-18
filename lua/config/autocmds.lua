-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- what follows are not autocmds, but we need them loading after the verylazy event

-- Make active window more visible
vim.api.nvim_set_hl(0, "NormalNC", { bg = "#222434" }) -- inactive window background
vim.api.nvim_set_hl(0, "Normal", { bg = "#161626" }) -- active window background
vim.api.nvim_set_hl(0, "WinSeparatorNC", { fg = "#cae797", bg = "#222434" }) -- inactive window separator
vim.api.nvim_set_hl(0, "WinSeparator", { fg = "#cae797", bg = "#222434" }) -- active window separator
vim.opt.winhl = "WinSeparator:WinSeparator"
-- Enable window borders globally
vim.opt.number = true -- This helps with left border visibility
vim.opt.relativenumber = true -- Optional
vim.opt.signcolumn = "yes" -- This helps ensure left border space
vim.opt.foldcolumn = "1" -- This can help with left border too
-- Create autocmd for window focus
vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter", "WinLeave", "BufLeave" }, {
  callback = function()
    local wins = vim.api.nvim_list_wins()
    for _, w in ipairs(wins) do
      if w == vim.api.nvim_get_current_win() then
        -- Current window gets highlighted border and background
        vim.wo[w].winhighlight = "WinSeparator:WinSeparator,Normal:Normal"
      else
        -- Other windows get dim border and background
        vim.wo[w].winhighlight = "WinSeparator:WinSeparatorNC,Normal:NormalNC"
      end
    end
  end,
})

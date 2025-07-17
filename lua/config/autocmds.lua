-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- what follows are not autocmds, but we need them loading after the verylazy event

-- -- Define custom highlight groups for tabs with a bright blue background
-- vim.api.nvim_set_hl(0, "TabLineSel", { fg = "#ffffff", bg = "#5f87af", bold = false }) -- Selected tab
-- vim.api.nvim_set_hl(
--   0,
--   "TabLine",
--   -- { fg = "#ffffff", bg = "#14161b", bold = false }
--   { fg = "#ffffff", bg = "NONE", bold = false }
-- ) -- Non-selected tabs

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

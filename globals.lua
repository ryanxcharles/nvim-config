-- Show line numbers by default
vim.opt.number = true
vim.opt.relativenumber = true

-- Number of spaces for a tab by default
vim.opt.tabstop = 2 -- Number of spaces for a tab
vim.opt.shiftwidth = 2 -- Number of spaces for auto-indent
vim.opt.expandtab = true -- Use spaces instead of tabs
vim.opt.autoindent = true -- Auto-indent new lines
vim.opt.smartindent = true -- Smart indenting for C-like languages

-- Two spaces for TypeScript/JavaScript/lua
vim.api.nvim_create_autocmd("FileType", {
  pattern = {
    "javascript",
    "typescript",
    "javascriptreact",
    "typescriptreact",
    "lua",
    "markdown",
    "css",
  },
  callback = function()
    vim.bo.tabstop = 2 -- Number of spaces for a tab
    vim.bo.shiftwidth = 2 -- Number of spaces for auto-indent
    vim.bo.expandtab = true -- Use spaces instead of tabs
    vim.opt_local.autoindent = true -- Auto-indent new lines
    vim.opt_local.smartindent = true -- Smart indenting for C-like languages
  end,
})

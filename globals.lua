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

-- Special rules for markdown - fix indenting and disable auto-indenting for lists
vim.api.nvim_create_autocmd("FileType", {
  pattern = {
    "markdown",
  },
  callback = function()
    vim.opt_local.indentexpr = ""
    vim.opt_local.formatoptions:remove("o") -- Prevent auto-indenting for lists
  end,
})

-- Create an autocmd to manually set TOML syntax for front matter inside Markdown
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  group = vim.api.nvim_create_augroup("MarkdownFrontmatter", { clear = true }),
  pattern = "*.md",
  callback = function()
    local first_line = vim.fn.getline(1)
    local third_line = vim.fn.getline(3)

    -- Check if the front matter matches '+++'
    if first_line:match("^%+%+%+") and third_line:match("^%+%+%+") then
      vim.fn.matchadd("toml", "^%+%+%+")
      vim.bo.syntax = "markdown" -- Set the syntax to markdown
    end
  end,
})

-- Create a custom command :Lint to run biome lint with --fix and --unsafe options
-- This is useful for sorting tailwind classes
vim.api.nvim_create_user_command("Fix", function()
  -- Get the current file path
  local current_file = vim.api.nvim_buf_get_name(0)

  -- Run Biome lint with --fix and --unsafe on the current file
  vim.cmd("!biome lint --fix --unsafe " .. current_file)
end, {})


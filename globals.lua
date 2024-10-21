local opts = { noremap = true, silent = true }

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

-- Special rules for markdown - fix indenting and disable auto-indenting for lists
vim.api.nvim_create_autocmd("FileType", {
  pattern = {
    "markdown",
  },
  callback = function()
    vim.opt_local.indentexpr = ""
    vim.opt_local.formatoptions:remove("o") -- Prevent auto-indenting for lists
    vim.opt_local.foldenable = false -- Disable folding by default
  end,
})

-- Create a custom command :Fix to run biome lint with --fix and --unsafe options
-- This is useful for sorting tailwind classes
vim.api.nvim_create_user_command("Fix", function()
  -- Get the current file path and directory
  local current_file = vim.api.nvim_buf_get_name(0)
  local file_dir = vim.fn.fnamemodify(current_file, ":h")

  -- Change to the file's directory, run biome, then change back
  vim.cmd("lcd " .. vim.fn.fnameescape(file_dir)) -- Temporarily change directory
  vim.cmd("!biome lint --fix --unsafe " .. vim.fn.fnameescape(current_file)) -- Run biome command
  vim.cmd("lcd -") -- Return to the original directory
end, {})

-- Autocommand for leaving a window (inactive)
vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
  callback = function()
    vim.wo.winhighlight = "Normal:InactiveWindow" -- Set inactive window background
  end,
})

-- lua-specific setup. reload current lua file.
function ReloadCurrentFile()
  local file = vim.fn.expand("%:r") -- Get the file path without extension
  package.loaded[file] = nil
  require(file)
end

-- Keybinding to reload the current Lua file
vim.api.nvim_set_keymap("n", "<Leader>rf", ":lua ReloadCurrentFile()<CR>", opts)

-- close hidden buffers. useful for aggs, argdo, ...
function CloseHiddenBuffers()
  local visible_buffers = {}
  -- Get all buffers visible in the current tabs and windows
  for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
      local buf = vim.api.nvim_win_get_buf(win)
      visible_buffers[buf] = true
    end
  end

  -- Iterate over all buffers and close the ones that are not visible
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if not visible_buffers[buf] and vim.api.nvim_buf_is_loaded(buf) then
      vim.cmd("bd " .. buf)
    end
  end
end

-- Create a command to call the function
vim.api.nvim_create_user_command("CloseHiddenBuffers", CloseHiddenBuffers, {})

-- open a terminal in a new vertical split to the right
vim.api.nvim_create_user_command("Term", function()
  vim.cmd("vnew")
  vim.cmd("term")
  vim.cmd("wincmd L")
end, {})

-- open a terminal in a new horizontal split below
vim.api.nvim_create_user_command("TermBelow", function()
  vim.cmd("new")
  vim.cmd("term")
  vim.cmd("wincmd J")
end, {})

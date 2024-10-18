local opts = { noremap = true, silent = true }

-- Redefine the :only command to include :e
-- This is useful specifically for:
-- :Git diff | Only
vim.cmd([[
  command! -bar Only execute 'only' | execute 'edit' | redraw!
]])

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
      vim.cmd('bd ' .. buf)
    end
  end
end

-- Create a command to call the function
vim.api.nvim_create_user_command('CloseHiddenBuffers', CloseHiddenBuffers, {})

-- open a terminal in a new vertical split to the right
vim.api.nvim_create_user_command('Term', function()
  vim.cmd('vnew')
  vim.cmd('term')
  vim.cmd('wincmd L')
end, {})

-- open a terminal in a new horizontal split below
vim.api.nvim_create_user_command('TermBelow', function()
  vim.cmd('new')
  vim.cmd('term')
  vim.cmd('wincmd J')
end, {})

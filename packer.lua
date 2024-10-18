local opts = { noremap = true, silent = true }
-- Neo-tree setup (neotree)
require("neo-tree").setup({
  close_if_last_window = true, -- Closes Neo-tree if it's the last open window
  popup_border_style = "rounded", -- Rounded border for popups
  enable_git_status = true, -- Show git status icons
  enable_diagnostics = true, -- Show LSP diagnostics in the file tree
  filesystem = {
    follow_current_file = true, -- Automatically focus on the current file
    use_libuv_file_watcher = true, -- Automatically refresh the tree when files change
    filtered_items = {
      hide_dotfiles = false,
    },
  },
  buffers = {
    follow_current_file = true, -- Automatically focus on the current buffer
  },
  git_status = {
    window = {
      position = "float", -- Open a floating window for git status
    },
  },
})

-- Keybinding to toggle Neo-tree
vim.api.nvim_set_keymap("n", "<Leader>tt", ":Neotree toggle<CR>", opts)
-- Neo-tree files
vim.api.nvim_set_keymap("n", "<Leader>tf", ":Neotree filesystem<CR>", opts)
-- Neo-tree buffers
vim.api.nvim_set_keymap("n", "<Leader>tb", ":Neotree buffers<CR>", opts)
-- Neo-tree git status
vim.api.nvim_set_keymap("n", "<Leader>tg", ":Neotree git_status<CR>", opts)
-- Keybinding to open Neo-tree buffer list in a floating window (on-demand)
vim.api.nvim_set_keymap(
  "n",
  "<Leader>fb",
  ":Neotree buffers position=float<CR>",
  opts
)
-- Keybinding to open Neo-tree buffer list in a floating window (on-demand)
vim.api.nvim_set_keymap(
  "n",
  "<Leader>ff",
  ":Neotree filesystem position=float<CR>",
  opts
)

-- Redefine the :only command to include :e
-- This is useful specifically for:
-- :Git diff | Only
vim.cmd([[
  command! -bar Only execute 'only' | execute 'edit' | redraw!
]])

-- Codewindow setup
-- local codewindow = require("codewindow")
-- codewindow.setup({
--   -- <Leader>mo - open the minimap
--   -- <Leader>mc - close the minimap
--   -- <Leader>mf - focus/unfocus the minimap
--   -- <Leader>mm - toggle the minimap
--   minimap_width = 10,
--   auto_enable = false,
--   -- no window border
--   -- border options: 'none', 'single', 'double'
--   window_border = "single",
-- })
-- codewindow.apply_default_keybinds()

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
vim.api.nvim_set_hl(0, "InactiveWindow", { bg = "#14161b" }) -- Inactive window background color

-- Autocommand for entering a window (active)
vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
  callback = function()
    vim.wo.winhighlight = "Normal:ActiveWindow" -- Set active window background
  end,
})

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

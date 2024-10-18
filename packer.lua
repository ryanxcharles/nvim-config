local opts = { noremap = true, silent = true }
-- lualine is great for the statusline, but I decided to create my own custom
-- tabline for how I deal with tabs. There is some setup code to begin with,
-- and then a custom function for the tabline.

-- Function to get diagnostic counts for a buffer
local function get_diagnostics(bufnr)
  local diagnostics = vim.diagnostic.get(bufnr)
  local counts = { error = 0, warn = 0, info = 0, hint = 0 }

  -- Count the diagnostics by severity
  for _, diagnostic in ipairs(diagnostics) do
    if diagnostic.severity == vim.diagnostic.severity.ERROR then
      counts.error = counts.error + 1
    elseif diagnostic.severity == vim.diagnostic.severity.WARN then
      counts.warn = counts.warn + 1
    elseif diagnostic.severity == vim.diagnostic.severity.INFO then
      counts.info = counts.info + 1
    elseif diagnostic.severity == vim.diagnostic.severity.HINT then
      counts.hint = counts.hint + 1
    end
  end

  return counts
end

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
  { fg = "#ffffff", bg = "#14161b", bold = false }
) -- Non-selected tabs

-- Get the background colors for TabLine and TabLineSel
local tabline_bg =
  vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID("TabLine")), "bg")
local tabline_sel_bg =
  vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID("TabLineSel")), "bg")

-- Define custom highlight groups for diagnostics with specified backgrounds
vim.api.nvim_set_hl(
  0,
  "TabLineDiagError",
  { fg = "#ff6c6b", bg = tabline_bg, bold = true }
)
vim.api.nvim_set_hl(
  0,
  "TabLineDiagWarn",
  { fg = "#ECBE7B", bg = tabline_bg, bold = true }
)
vim.api.nvim_set_hl(
  0,
  "TabLineDiagInfo",
  { fg = "#51afef", bg = tabline_bg, bold = true }
)
vim.api.nvim_set_hl(
  0,
  "TabLineDiagHint",
  { fg = "#98be65", bg = tabline_bg, bold = true }
)

-- Define custom highlight groups for the selected tab
vim.api.nvim_set_hl(
  0,
  "TabLineDiagErrorSel",
  { fg = "#ff6c6b", bg = tabline_sel_bg, bold = true }
)
vim.api.nvim_set_hl(
  0,
  "TabLineDiagWarnSel",
  { fg = "#ECBE7B", bg = tabline_sel_bg, bold = true }
)
vim.api.nvim_set_hl(
  0,
  "TabLineDiagInfoSel",
  { fg = "#51afef", bg = tabline_sel_bg, bold = true }
)
vim.api.nvim_set_hl(
  0,
  "TabLineDiagHintSel",
  { fg = "#98be65", bg = tabline_sel_bg, bold = true }
)

-- Set up a global variable to keep track of how many tabs to subtract - see my
-- explanation below
_G.subtract_last_tabs_N = 0

-- Custom tabline function to display all window names in each tab
function MyTabline()
  local s = ""
  local tabpages = vim.api.nvim_list_tabpages()
  local current_tabpage = vim.api.nvim_get_current_tabpage()

  local total_tabs = #tabpages or 0

  -- Ensure that subtract_last_tabs_N does not exceed the total number of tabs
  if _G.subtract_last_tabs_N >= total_tabs then
    _G.subtract_last_tabs_N = total_tabs - 1
  end

  -- Calculate how many tabs to show
  local max_visible_tabs = total_tabs - _G.subtract_last_tabs_N

  -- Loop through each visible tab
  for i = 1, max_visible_tabs do
    local tabpage = tabpages[i]
    local windows = vim.api.nvim_tabpage_list_wins(tabpage) -- Get all windows in the tab
    local tab_str = ""

    local tab_highlight_color = ""
    if tabpage == current_tabpage then
      tab_highlight_color = "%#TabLineSel#"
    else
      tab_highlight_color = "%#TabLine#"
    end

    -- Loop through each window in the tab
    for _, win in ipairs(windows) do
      local bufnr = vim.api.nvim_win_get_buf(win)
      local bufname = vim.fn.fnamemodify(vim.fn.bufname(bufnr), ":t")
        or "[No Name]"
      local modified = vim.bo[bufnr].modified and " [+]" or ""
      local diagnostic = get_diagnostics(bufnr)

      -- Extract the first letter of each folder in the path
      local path_letters = ""
      local full_path = vim.fn.fnamemodify(vim.fn.bufname(bufnr), ":.")
      local folders = vim.split(vim.fn.fnamemodify(full_path, ":h"), "/")
      for _, folder in ipairs(folders) do
        if folder ~= "" then
          path_letters = path_letters .. folder:sub(1, 1) .. "/"
        end
      end

      -- Build the diagnostic string (only show non-zero counts)
      local diagnostic_str = ""
      if diagnostic.error > 0 then
        diagnostic_str = diagnostic_str
          .. (tabpage == current_tabpage and "%#TabLineDiagErrorSel#" or "%#TabLineDiagError#")
          .. "  "
          .. diagnostic.error
          .. tab_highlight_color
      end
      if diagnostic.warn > 0 then
        diagnostic_str = diagnostic_str
          .. (tabpage == current_tabpage and "%#TabLineDiagWarnSel#" or "%#TabLineDiagWarn#")
          .. "  "
          .. diagnostic.warn
          .. tab_highlight_color
      end
      if diagnostic.info > 0 then
        diagnostic_str = diagnostic_str
          .. (tabpage == current_tabpage and "%#TabLineDiagInfoSel#" or "%#TabLineDiagInfo#")
          .. "  "
          .. diagnostic.info
          .. tab_highlight_color
      end
      if diagnostic.hint > 0 then
        diagnostic_str = diagnostic_str
          .. (tabpage == current_tabpage and "%#TabLineDiagHintSel#" or "%#TabLineDiagHint#")
          .. "  "
          .. diagnostic.hint
          .. tab_highlight_color
      end

      -- Append the buffer name and diagnostics to the tab string
      -- if not string.find(bufname, "-MINIMAP-") then -- Exclude Minimap buffers if present
      if
        not string.find(bufname, "CodeWindow")
        and not (
          string.find(bufname, "neo")
          and string.find(bufname, "tree filesystem")
        )
      then -- Exclude Codewindow buffers if present
        tab_str = tab_str
          .. " "
          .. path_letters
          .. bufname
          .. diagnostic_str
          .. modified
          .. " |"
      end
    end

    -- Remove trailing " | " from the last window in the tab
    tab_str = tab_str:sub(1, -3)

    -- Highlight the current tab
    s = s .. tab_highlight_color .. tab_str .. " %#TabLine#"
  end

  -- Add the right scroll indicator if there are hidden tabs
  if _G.subtract_last_tabs_N > 0 then
    s = s .. "%#TabLineSel# > %#TabLine#"
  end

  return s
end

-- Set the custom tabline
vim.o.tabline = "%!v:lua.MyTabline()"

-- Always show the tabline
vim.opt.showtabline = 2

-- Function to refresh the tabline
function _G.refresh_tabline()
  -- Only refresh the tabline if the current buffer is valid
  if vim.api.nvim_buf_is_valid(vim.api.nvim_get_current_buf()) then
    vim.cmd("redrawtabline")
  end
end

-- Set up an autocmd to refresh the tabline whenever diagnostics change
vim.api.nvim_create_autocmd("DiagnosticChanged", {
  pattern = "*",
  callback = function()
    local ft = vim.bo.filetype
    -- Do not run the diagnostic refresh for specific filetypes
    if
      ft ~= "packer"
      and vim.api.nvim_buf_is_valid(vim.api.nvim_get_current_buf())
    then
      _G.refresh_tabline()
    end
  end,
})

-- The custom tabline is set up, but sometimes it is too long. Because nvim
-- automatically renders only the last portion of the tabline, my solution to
-- tab scrolling is to have some key shortcuts to render only the last number
-- of tabs. By keying to the left, you remove the display of the last tab, and
-- by keying to the right, you add it back. This is kind of a hack, but it
-- shouldn't normally happen, because you should keep the number of tabs
-- visible on the screen normally.

-- Keybinding to scroll left (increase subtract_last_tabs_N)
vim.api.nvim_set_keymap(
  "n",
  "<Leader>th",
  ":lua _G.subtract_last_tabs_N = _G.subtract_last_tabs_N + 1; _G.refresh_tabline()<CR>",
  opts
)

-- Keybinding to scroll right (decrease subtract_last_tabs_N)
vim.api.nvim_set_keymap(
  "n",
  "<Leader>tl",
  ":lua _G.subtract_last_tabs_N = math.max(0, _G.subtract_last_tabs_N - 1); _G.refresh_tabline()<CR>",
  opts
)

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

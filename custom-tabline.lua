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

  -- Define the threshold for showing filenames
  local show_filenames = total_tabs <= 10

  -- Loop through each visible tab
  for i = 1, total_tabs do
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
      local bufname = vim.fn.fnamemodify(vim.fn.bufname(bufnr), ":t") or "[No Name]"
      local diagnostic = get_diagnostics(bufnr)

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

      -- Append tab number and diagnostics if more than 5 tabs
      if show_filenames then
        local modified = vim.bo[bufnr].modified and " [+]" or ""
        tab_str = tab_str .. " " .. bufname .. diagnostic_str .. modified .. " |"
      else
        -- Display tab number instead of filename when there are more than 5 tabs
        tab_str = tab_str .. " Tab " .. i .. diagnostic_str .. " |"
      end
    end

    -- Remove trailing " | " from the last window in the tab
    tab_str = tab_str:sub(1, -3)

    -- Highlight the current tab
    s = s .. tab_highlight_color .. tab_str .. " %#TabLine#"
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


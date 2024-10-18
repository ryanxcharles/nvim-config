-- Define a custom theme for lualine
local bright_theme = {
  normal = {
    a = { fg = "#ffffff", bg = "#5f87af", gui = "bold" }, -- Blue-gray for normal mode
    b = { fg = "#ffffff", bg = "#3a3a3a" }, -- Dark background for section b
    c = { fg = "#ffffff", bg = "#14161b" }, -- Even darker for section c
  },
  insert = { a = { fg = "#ffffff", bg = "#87af5f", gui = "bold" } }, -- Green for insert mode
  visual = { a = { fg = "#ffffff", bg = "#d7af5f", gui = "bold" } }, -- Yellow for visual mode
  replace = { a = { fg = "#ffffff", bg = "#d75f5f", gui = "bold" } }, -- Red for replace mode
  command = { a = { fg = "#ffffff", bg = "#af5fff", gui = "bold" } }, -- Purple for command mode
  inactive = {
    a = { fg = "#bcbcbc", bg = "#3a3a3a", gui = "bold" }, -- Gray for inactive mode
    b = { fg = "#bcbcbc", bg = "#14161b" },
    c = { fg = "#bcbcbc", bg = "#14161b" },
  },
}

-- Customize the statusline with lualine
require("lualine").setup({
  options = {
    theme = bright_theme, -- Use our custom bright theme
    section_separators = { "▶️", "◀️" }, -- Use arrow emojis as section separators
    component_separators = { "|", "|" }, -- Use simple vertical bars as component separators
    disabled_filetypes = {}, -- Disable for specific filetypes if needed
  },
  sections = {
    lualine_a = { "mode" }, -- Shows the current mode (e.g., Insert, Normal, etc.)
    lualine_b = { "branch", "diff", "diagnostics" },
    lualine_c = {
      {
        "filename", -- Shows the current file name
        path = 1, -- 1 = relative path, 2 = absolute path
      },
      {
        function()
          return vim.fn.getcwd() -- Displays the CWD
        end,
        icon = "📁", -- Optional: Add a folder icon
      },
      {
        "diagnostics",
        sources = { "nvim_lsp" },
        sections = { "error", "warn", "info", "hint" },
        diagnostics_color = {
          error = { fg = "#ff6c6b" }, -- Brighter Error color (red)
          warn = { fg = "#ECBE7B" }, -- Brighter Warning color (yellow)
          info = { fg = "#51afef" }, -- Brighter Info color (cyan)
          hint = { fg = "#98be65" }, -- Brighter Hint color (green)
        },
        symbols = {
          error = " ", -- Error icon
          warn = " ", -- Warning icon
          info = " ", -- Info icon
          hint = " ", -- Hint icon
        },
        colored = true, -- Color the diagnostics
        update_in_insert = false, -- Update diagnostics in insert mode
        always_visible = false, -- Always show diagnostics, even if 0
      },
    },
    lualine_x = { "encoding", "fileformat", "filetype" }, -- Shows encoding, file format, and type
    lualine_y = { "progress" }, -- Shows file progress (percentage through file)
    lualine_z = { "location" }, -- Shows line and column number
  },
  inactive_sections = {},
  tabline = {},
  extensions = {},
})

-- Create an autocmd to refresh lualine when the directory changes
vim.api.nvim_create_autocmd("DirChanged", {
  pattern = "*",
  callback = function()
    require("lualine").refresh() -- Refresh lualine to reflect the new CWD
  end,
})

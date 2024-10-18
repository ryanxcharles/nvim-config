local opts = { noremap = true, silent = true }

-- rust: integration with crates.nvim for managing dependencies
require("crates").setup({
  null_ls = {
    enabled = true, -- Enable null-ls integration (optional)
    name = "crates.nvim",
  },
})

-- Optional keybinding to update dependencies with `crates.nvim`
vim.api.nvim_set_keymap(
  "n",
  "<Leader>cu",
  ":lua require('crates').update_crate()<CR>",
  { noremap = true, silent = true }
)

-- Create a custom command :Lint to run biome lint with --fix and --unsafe options
-- This is useful for sorting tailwind classes
vim.api.nvim_create_user_command("Fix", function()
  -- Get the current file path
  local current_file = vim.api.nvim_buf_get_name(0)

  -- Run Biome lint with --fix and --unsafe on the current file
  vim.cmd("!biome lint --fix --unsafe " .. current_file)
end, {})

local cmp = require("cmp")

-- Set up nvim-cmp (auto-complete)
---@diagnostic disable-next-line: redundant-parameter
cmp.setup({
  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body) -- For `luasnip` users.
    end,
  },
  mapping = {
    ---@diagnostic disable-next-line: undefined-field
    ["<C-Space>"] = cmp.mapping.complete(), -- Trigger completion manually
    ---@diagnostic disable-next-line: undefined-field
   ["<CR>"] = cmp.mapping(function(fallback)
    ---@diagnostic disable-next-line: undefined-field
      if cmp.visible() and cmp.get_selected_entry() then
    ---@diagnostic disable-next-line: undefined-field
        cmp.confirm({ select = false }) -- Only confirm if an item is explicitly selected
      else
        fallback() -- Otherwise, fallback to the default Enter behavior
      end
    end, { "i", "s" }), -- Supports insert and select mode
    ---@diagnostic disable-next-line: undefined-field
    ["<C-.>"] = cmp.mapping.select_next_item(), -- Navigate completion next
    ---@diagnostic disable-next-line: undefined-field
    ["<C-,>"] = cmp.mapping.select_prev_item(), -- Navigate completion previous
  },
  sources = {
    { name = "nvim_lsp" }, -- LSP completions (TypeScript, etc.)
    { name = "buffer" }, -- Completions from current buffer
    { name = "path" }, -- Path completions
    { name = "luasnip" }, -- Snippet completions
    { name = "npm", keyword_length = 3 }, -- NPM package completions
  },
  formatting = {
    format = require("tailwindcss-colorizer-cmp").formatter,
  },
})

local uv = vim.loop -- Use Neovim's built-in libuv wrapper for filesystem operations

-- Function to recursively search for a file in the current directory or any parent directory
local function find_file_in_parents(filename)
  ---@diagnostic disable-next-line: undefined-field
  local cwd = uv.cwd() -- Get the current working directory

  while cwd do
    local filepath = cwd .. "/" .. filename
    ---@diagnostic disable-next-line: undefined-field
    local stat = uv.fs_stat(filepath)
    if stat then
      return true -- File found
    end

    -- Move to the parent directory
    local parent = cwd:match("(.*/)[^/]+/?$")
    if parent == cwd then
      break -- Reached the root directory
    end
    cwd = parent
  end

  return false -- File not found in any parent directory
end

-- Formatter setup for any languages that need it
require("formatter").setup({
  filetype = {
    markdown = {
      -- Prettier for formatting Markdown
      function()
        return {
          exe = "prettier", -- Make sure Prettier is installed globally
          args = {
            "--stdin-filepath",
            vim.api.nvim_buf_get_name(0), -- Prettier needs the file path to infer formatting rules
            "--prose-wrap",
            "always", -- Ensures text in markdown files is always wrapped
          },
          stdin = true,
        }
      end,
    },
    -- other filetypes here...
    typescript = {
      function()
        -- Detect if this is a Deno project by looking for a 'deno.json' or 'deno.jsonc'
        if
          find_file_in_parents("deno.json")
          or find_file_in_parents("deno.jsonc")
        then
          return {
            exe = "deno",
            args = { "fmt", "-" }, -- Format via stdin
            stdin = true,
          }
        else
          -- Use Biome for non-Deno TypeScript projects
          return {
            exe = "biome",
            args = {
              "format",
              "--stdin-file-path",
              vim.api.nvim_buf_get_name(0),
              "--write",
            },
            stdin = true,
          }
        end
      end,
    },
    typescriptreact = {
      function()
        if
          find_file_in_parents("deno.json")
          or find_file_in_parents("deno.jsonc")
        then
          return {
            exe = "deno",
            args = { "fmt", "-" }, -- Format via stdin
            stdin = true,
          }
        else
          return {
            exe = "biome",
            args = {
              "format",
              "--stdin-file-path",
              vim.api.nvim_buf_get_name(0),
              "--write",
            },
            stdin = true,
          }
        end
      end,
    },
    json = {
      -- Conditional formatter for JSON files
      function()
        if
          find_file_in_parents("deno.json")
          or find_file_in_parents("deno.jsonc")
        then
          return {
            exe = "deno",
            args = {
              "fmt", -- Format command
              vim.api.nvim_buf_get_name(0), -- Pass the current file path to Deno
            },
            stdin = false, -- We’re passing the filename, not using stdin
          }
        else
          return {
            exe = "biome",
            args = {
              "format",
              "--stdin-file-path",
              vim.api.nvim_buf_get_name(0),
              "--write",
            },
            stdin = true,
          }
        end
      end,
    },
    jsonc = {
      -- Conditional formatter for JSONC files
      function()
        if
          find_file_in_parents("deno.json")
          or find_file_in_parents("deno.jsonc")
        then
          return {
            exe = "deno",
            args = {
              "fmt", -- Format command
              vim.api.nvim_buf_get_name(0), -- Pass the current file path to Deno
            },
            stdin = false, -- We’re passing the filename, not using stdin
          }
        else
          return {
            exe = "biome",
            args = {
              "format",
              "--stdin-file-path",
              vim.api.nvim_buf_get_name(0),
              "--write",
            },
            stdin = true,
          }
        end
      end,
    },
    javascript = {
      function()
        if
          find_file_in_parents("deno.json")
          or find_file_in_parents("deno.jsonc")
        then
          return {
            exe = "deno",
            args = { "fmt", "-" }, -- Format via stdin
            stdin = true,
          }
        else
          return {
            exe = "biome",
            args = {
              "format",
              "--stdin-file-path",
              vim.api.nvim_buf_get_name(0),
              "--write",
            },
            stdin = true,
          }
        end
      end,
    },
    javascriptreact = {
      function()
        if
          find_file_in_parents("deno.json")
          or find_file_in_parents("deno.jsonc")
        then
          return {
            exe = "deno",
            args = { "fmt", "-" }, -- Format via stdin
            stdin = true,
          }
        else
          return {
            exe = "biome",
            args = {
              "format",
              "--stdin-file-path",
              vim.api.nvim_buf_get_name(0),
              "--write",
            },
            stdin = true,
          }
        end
      end,
    },
    lua = {
      function()
        return {
          exe = "stylua",
          args = { "--search-parent-directories", "-" },
          stdin = true,
        }
      end,
    },
    rust = {
      function()
        return {
          exe = "rustfmt",
          args = { "--emit", "stdout" },
          stdin = true,
        }
      end,
    },
  },
})

-- Enable colorizer for CSS, HTML, JavaScript, and more, but not Tailwind
-- require("colorizer").setup({
--   filetypes = {
--     "html",
--     "css",
--     "javascript",
--     "typescript",
--     "javascriptreact",
--     "typescriptreact",
--   },
--   user_default_options = {
--     RGB = true, -- #RGB hex codes
--     RRGGBB = true, -- #RRGGBB hex codes
--     names = true, -- "Name" codes like Blue or blue
--     RRGGBBAA = false, -- #RRGGBBAA hex codes
--     AARRGGBB = false, -- 0xAARRGGBB hex codes
--     rgb_fn = false, -- CSS rgb() and rgba() functions
--     hsl_fn = false, -- CSS hsl() and hsla() functions
--     css = false, -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
--     css_fn = false, -- Enable all CSS *functions*: rgb_fn, hsl_fn
--     -- Available modes for `mode`: foreground, background,  virtualtext
--     mode = "background", -- Set the display mode.
--     -- True is same as normal
--     tailwind = false, -- Disable tailwind colors (using tailwind-tools instead)
--     -- parsers can contain values used in |user_default_options|
--     sass = { enable = false, parsers = { "css" } }, -- Enable sass colors
--     virtualtext = "■",
--     -- update color values even if buffer is not focused
--     -- example use: cmp_menu, cmp_docs
--     always_update = false,
--   },
--   -- all the sub-options of filetypes apply to buftypes
--   buftypes = {},
-- })

-- Accurate syntax highlighting for TypeScript and other languages
---@diagnostic disable-next-line: missing-fields
require("nvim-treesitter.configs").setup({
  -- Install parsers for various languages
  ensure_installed = {
    "javascript",
    "typescript",
    "tsx",
    "json",
    "jsonc",
    "jsdoc",
    "html",
    "css",
    "rust",
    "markdown",
    "markdown_inline",
    "toml",
    "wgsl",
  }, -- Add more languages as needed

  -- Enable Treesitter-based syntax highlighting
  highlight = {
    enable = true, -- Enable Treesitter highlighting
    additional_vim_regex_highlighting = false, -- Disable Vim's regex-based highlighting
  },

  -- You can enable more Treesitter features as needed (optional)
  indent = { enable = true }, -- Enable Treesitter-based indentation (optional)

  -- Folding
  fold = { enable = true }, -- Enable Treesitter-based folding (optional)
})

-- Use Treesitter for folding
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldenable = false -- Disable folding by default

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

-- GitHub Copilot

-- Copilot uses tab to accept suggestions by default. If you want to use tab for
-- something else, you can disable this behavior.
-- vim.g.copilot_no_tab_map = true

-- Set custom keybindings for cycling through Copilot suggestions
vim.api.nvim_set_keymap(
  "i",
  "<C-n>",
  "copilot#Next()",
  { silent = true, expr = true }
)
vim.api.nvim_set_keymap(
  "i",
  "<C-p>",
  "copilot#Previous()",
  { silent = true, expr = true }
)

-- Custom color for search highlighting
vim.api.nvim_set_hl(0, "Search", { bg = "#87af5f", fg = "#000000" })
-- Custom color for visual mode
vim.api.nvim_set_hl(0, "Visual", { bg = "#5f87af", fg = "#ffffff" })
-- Custom color for incremental search
vim.api.nvim_set_hl(0, "IncSearch", { bg = "#875fff", fg = "#ffffff" })

-- -- Define subtle colors for the rainbow delimiters
-- -- highlight RainbowDelimiterBlue guifg=#5F9EA0  -- Cadet Blue
-- -- highlight RainbowDelimiterGreen guifg=#8FBC8F  -- Dark Sea Green
-- -- highlight RainbowDelimiterCyan guifg=#7AC5CD   -- Medium Aquamarine
-- -- highlight RainbowDelimiterGray guifg=#A9A9A9   -- Dark Gray
-- -- highlight RainbowDelimiterViolet guifg=#9370DB -- Medium Purple
-- -- highlight RainbowDelimiterLightBlue guifg=#ADD8E6 -- Light Blue
-- -- highlight RainbowDelimiterLightGray guifg=#D3D3D3 -- Light Gray
-- vim.cmd([[
--   highlight RainbowDelimiterBlue guifg=#5F9EA0
--   highlight RainbowDelimiterGreen guifg=#8FBC8F
--   highlight RainbowDelimiterCyan guifg=#7AC5CD
--   highlight RainbowDelimiterGray guifg=#A9A9A9
--   highlight RainbowDelimiterViolet guifg=#9370DB
--   highlight RainbowDelimiterLightBlue guifg=#ADD8E6
--   highlight RainbowDelimiterLightGray guifg=#D3D3D3
-- ]])
--
-- local rainbow_delimiters = require("rainbow-delimiters")
--
-- vim.g.rainbow_delimiters = {
--   strategy = {
--     [""] = rainbow_delimiters.strategy["global"],
--     vim = rainbow_delimiters.strategy["local"],
--   },
--   query = {
--     [""] = "rainbow-delimiters",
--     lua = "rainbow-blocks",
--   },
--   highlight = {
--     "RainbowDelimiterBlue",
--     "RainbowDelimiterGreen",
--     "RainbowDelimiterCyan",
--     "RainbowDelimiterGray",
--     "RainbowDelimiterViolet",
--     "RainbowDelimiterLightBlue",
--     "RainbowDelimiterLightGray",
--   },
-- }

-- Define a custom bright theme for lualine
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

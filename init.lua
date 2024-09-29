-- ~/.config/nvim/init.lua
require("packer").startup(function()
  use("wbthomason/packer.nvim") -- Packer manages itself
  use("nvim-telescope/telescope.nvim") -- Telescope
  use("nvim-lua/plenary.nvim") -- Required by telescope
  use("wfxr/minimap.vim") -- Use ":Minimap"
  use("neovim/nvim-lspconfig") -- language server for typescript, etc.

  -- a series of auto-complete related plugins
  use("hrsh7th/nvim-cmp") -- Autocompletion plugin
  use("hrsh7th/cmp-nvim-lsp") -- LSP source for nvim-cmp
  use("hrsh7th/cmp-buffer") -- Buffer source for nvim-cmp
  use("hrsh7th/cmp-path") -- Path source for nvim-cmp
  use("hrsh7th/cmp-cmdline") -- Command line completion
  use("saadparwaiz1/cmp_luasnip") -- Snippet completion
  use("L3MON4D3/LuaSnip") -- Snippet engine

  -- code formatting (e.g., using biome)
  use("mhartington/formatter.nvim")

  -- colorizer for HTML/CSS (but not Tailwind)
  use("norcalli/nvim-colorizer.lua")

  -- colors for Tailwind
  use("themaxmarchuk/tailwindcss-colors.nvim")

  -- accurate syntax highlighting for typescript
  use("nvim-treesitter/nvim-treesitter")

  -- github copilot
  use({ "github/copilot.vim" })
  use({
    "zbirenbaum/copilot-cmp",
    after = { "copilot.vim" },
    config = function()
      require("copilot_cmp").setup()
    end,
  })

  -- rainbow delimiters
  use("hiphish/rainbow-delimiters.nvim")

  -- npm package completion
  use("David-Kunz/cmp-npm")

  use({
    "nvim-lualine/lualine.nvim",
    requires = { "kyazdani42/nvim-web-devicons", opt = true }, -- Optional: File icons, but not required for diagnostics
  })
end)

-- Set space as the leader key
vim.g.mapleader = " "

local opts = { noremap = true, silent = true }

-- Enable 24-bit RGB color in the terminal
vim.opt.termguicolors = true

-- Show line numbers by default
vim.opt.number = true

-- Number of spaces for a tab
vim.opt.tabstop = 2

-- Key mappings using leader key
vim.api.nvim_set_keymap("n", "<leader>w", ":w<CR>", opts)
vim.api.nvim_set_keymap("n", "<leader>h", "gT", opts)
vim.api.nvim_set_keymap("n", "<leader>l", "gt", opts)
vim.api.nvim_set_keymap(
  "n",
  "<leader>n",
  ":tabnew<CR><leader>p",
  { silent = true }
)
vim.api.nvim_set_keymap("n", "<leader>q", ":q<CR>", opts)
vim.api.nvim_set_keymap("n", "<leader>e", ":e ", opts)

-- Window navigation
vim.api.nvim_set_keymap("n", ";h", ":wincmd h<CR>", opts)
vim.api.nvim_set_keymap("n", ";l", ":wincmd l<CR>", opts)
vim.api.nvim_set_keymap("n", ";k", ":wincmd k<CR>", opts)
vim.api.nvim_set_keymap("n", ";j", ":wincmd j<CR>", opts)
-- Move to window 1-9
vim.api.nvim_set_keymap("n", ";1", ":1wincmd w<CR>", opts)
vim.api.nvim_set_keymap("n", ";2", ":2wincmd w<CR>", opts)
vim.api.nvim_set_keymap("n", ";3", ":3wincmd w<CR>", opts)
vim.api.nvim_set_keymap("n", ";4", ":4wincmd w<CR>", opts)
vim.api.nvim_set_keymap("n", ";5", ":5wincmd w<CR>", opts)
vim.api.nvim_set_keymap("n", ";6", ":6wincmd w<CR>", opts)
vim.api.nvim_set_keymap("n", ";7", ":7wincmd w<CR>", opts)
vim.api.nvim_set_keymap("n", ";8", ":8wincmd w<CR>", opts)
vim.api.nvim_set_keymap("n", ";9", ":9wincmd w<CR>", opts)

-- Redraw screen
vim.api.nvim_set_keymap("n", "<leader>.", "<C-l>", opts)

-- TODO: test
-- Define a highlight group for TODO comments
vim.api.nvim_command("highlight TodoComment guifg=#FA8603 gui=bold") -- Orange color with bold
-- Automatically highlight TODO comments when entering a buffer
vim.api.nvim_exec(
  [[
  augroup TodoHighlight
    autocmd!
    autocmd BufEnter,BufReadPost * call matchadd('TodoComment', 'TODO:')
  augroup END
]],
  false
)

-- Key binding to use Telescope to search files
-- Set up keybinding to always show hidden files
vim.api.nvim_set_keymap(
  "n",
  "<leader>p",
  ":lua require('telescope.builtin').find_files({ hidden = true })<CR>",
  opts
)

-- Telscope search inside files with ripgrep (rg)
vim.api.nvim_set_keymap("n", "<leader>fg", ":Telescope live_grep<CR>", opts)

-- LSP integration with Telescope for TypeScript and other languages
-- Space + fs: Search document symbols (like variables, functions, etc.).
vim.api.nvim_set_keymap(
  "n",
  "<leader>fs",
  "<cmd>Telescope lsp_document_symbols<CR>",
  opts
)
-- Space + fr: Find all references to a symbol.
vim.api.nvim_set_keymap(
  "n",
  "<leader>fr",
  "<cmd>Telescope lsp_references<CR>",
  opts
)
-- Space + fd: Search through diagnostics (errors, warnings).
vim.api.nvim_set_keymap(
  "n",
  "<leader>fd",
  "<cmd>Telescope diagnostics<CR>",
  opts
)
-- Show all diagnostics on the current line in a floating window
vim.api.nvim_set_keymap(
  "n",
  "<leader>d",
  "<cmd>lua vim.diagnostic.open_float(nil, { focusable = false })<CR>",
  opts
)

require("telescope").setup({
  defaults = {
    vimgrep_arguments = {
      "rg", -- Ripgrep binary
      "--color=never",
      "--no-heading",
      "--with-filename",
      "--line-number",
      "--column",
      "--smart-case",
    },
    -- Other default settings
  },
})

-- Key bindind to reload init.lua file
vim.api.nvim_set_keymap(
  "n",
  "<leader>r",
  ":luafile ~/.config/nvim/init.lua<CR>",
  opts
)

-- two spaces for typescript/javascript/lua
vim.api.nvim_create_autocmd("FileType", {
  pattern = {
    "javascript",
    "typescript",
    "javascriptreact",
    "typescriptreact",
    "lua",
  },
  callback = function()
    vim.bo.tabstop = 2 -- Number of spaces for a tab
    vim.bo.shiftwidth = 2 -- Number of spaces for auto-indent
    vim.bo.expandtab = true -- Use spaces instead of tabs
  end,
})

-- TypeScript organize inputs
vim.api.nvim_set_keymap(
  "n",
  "<leader>oi",
  '<cmd>lua vim.lsp.buf.code_action({ context = { only = { "source.organizeImports" } }, apply = true })<CR>',
  opts
)

-- Import the LSP config plugin
local lspconfig = require("lspconfig")

-- TypeScript Language Server setup
lspconfig.ts_ls.setup({
  -- This function attaches common settings when the LSP attaches to a buffer
  on_attach = function(client, bufnr)
    -- Optionally, disable tsserver's formatting in favor of something like prettier
    client.server_capabilities.documentFormattingProvider = false

    -- Add keybindings for common LSP features
    local opts = opts

    -- Go to definition
    vim.api.nvim_buf_set_keymap(
      bufnr,
      "n",
      "gd",
      "<cmd>lua vim.lsp.buf.definition()<CR>",
      opts
    )

    -- Hover documentation
    vim.api.nvim_buf_set_keymap(
      bufnr,
      "n",
      "K",
      "<cmd>lua vim.lsp.buf.hover()<CR>",
      opts
    )

    -- Find references
    vim.api.nvim_buf_set_keymap(
      bufnr,
      "n",
      "gr",
      "<cmd>lua vim.lsp.buf.references()<CR>",
      opts
    )

    -- Go to implementation
    vim.api.nvim_buf_set_keymap(
      bufnr,
      "n",
      "gi",
      "<cmd>lua vim.lsp.buf.implementation()<CR>",
      opts
    )

    -- Rename symbol
    vim.api.nvim_buf_set_keymap(
      bufnr,
      "n",
      "<leader>rn",
      "<cmd>lua vim.lsp.buf.rename()<CR>",
      opts
    )

    -- Code actions
    vim.api.nvim_buf_set_keymap(
      bufnr,
      "n",
      "<leader>ca",
      "<cmd>lua vim.lsp.buf.code_action()<CR>",
      opts
    )
  end,

  -- Ensure the server uses the right config for each project directory
  root_dir = lspconfig.util.root_pattern("tsconfig.json"),

  -- Add additional configuration options if needed (e.g., filetypes)
  filetypes = { "typescript", "typescriptreact", "typescript.tsx" },

  -- Command to launch the TypeScript Language Server via the global `pnpm` path
  cmd = { "typescript-language-server", "--stdio" },

  -- Add capabilities for autocompletion
  capabilities = require("cmp_nvim_lsp").default_capabilities(),
})

lspconfig.biome.setup({
  on_attach = function(client, bufnr)
    -- Enable diagnostic messages (linting)
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      callback = function()
        vim.lsp.buf.format({ bufnr = bufnr })
      end,
    })
  end,
  cmd = { "biome", "lsp-proxy" },
  filetypes = {
    "javascript",
    "javascriptreact",
    "json",
    "jsonc",
    "typescript",
    "typescript.tsx",
    "typescriptreact",
    "astro",
    "svelte",
    "vue",
    "css",
  },
  root_dir = lspconfig.util.root_pattern("biome.json"),
  settings = {
    biome = {
      diagnostics = {
        enable = true, -- Enable linting diagnostics
      },
      format = {
        enable = true, -- Enable auto-formatting if desired
      },
    },
  },
})

-- Set up nvim-cmp (auto-complete)
local cmp = require("cmp")

cmp.setup({
  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body) -- For `luasnip` users.
    end,
  },
  mapping = {
    ["<C-Space>"] = cmp.mapping.complete(), -- Trigger completion manually
    ["<CR>"] = cmp.mapping.confirm({ select = true }), -- Confirm selection
    ["<Tab>"] = cmp.mapping.select_next_item(), -- Navigate completion with Tab
    ["<S-Tab>"] = cmp.mapping.select_prev_item(),
  },
  sources = {
    { name = "nvim_lsp" }, -- LSP completions (TypeScript, etc.)
    { name = "buffer" }, -- Completions from current buffer
    { name = "path" }, -- Path completions
    { name = "luasnip" }, -- Snippet completions
    { name = "npm", keyword_length = 3 }, -- NPM package completions
  },
})

require("formatter").setup({
  filetype = {
    lua = {
      -- StyLua
      function()
        return {
          exe = "stylua",
          args = { "--search-parent-directories", "-" },
          stdin = true,
        }
      end,
    },
    typescript = {
      function()
        return {
          exe = "biome", -- The Biome executable
          args = {
            "format",
            "--stdin-file-path",
            vim.api.nvim_buf_get_name(0),
            "--write",
          },
          stdin = true,
        }
      end,
    },
    typescriptreact = {
      function()
        return {
          exe = "biome", -- The Biome executable
          args = {
            "format",
            "--stdin-file-path",
            vim.api.nvim_buf_get_name(0),
            "--write",
          },
          stdin = true,
        }
      end,
    },
    javascript = {
      function()
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
      end,
    },
    javascriptreact = {
      -- Same for JavaScript files
      function()
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
      end,
    },
  },
})

-- TailwindCSS Language Server setup
lspconfig.tailwindcss.setup({
  on_attach = function(client, bufnr)
    -- Any additional LSP settings or keybindings you want for Tailwind
    require("tailwindcss-colors").buf_attach(bufnr)
  end,
  filetypes = { "html", "javascriptreact", "typescriptreact", "css" }, -- Add any other file types where you use Tailwind
})

-- TailwindCSS colors
require("tailwindcss-colors").setup()

-- Enable colorizer for CSS, HTML, JavaScript, and more, but not Tailwind
require("colorizer").setup({
  "css",
  "javascript",
  "javascriptreact",
  "typescriptreact",
  "html",
}, {
  RGB = true, -- #RGB hex codes
  RRGGBB = true, -- #RRGGBB hex codes
  names = false, -- Disable color names like "Red"
  RRGGBBAA = true, -- #RRGGBBAA hex codes
  rgb_fn = true, -- Enable rgb() and rgba() functions
  hsl_fn = true, -- Enable hsl() and hsla() functions
  css = true, -- Enable all CSS features: rgb_fn, hsl_fn, names, hex codes
  css_fn = true, -- Enable all CSS *functions*: rgb_fn, hsl_fn
})

-- Accurate syntax highlighting for TypeScript
require("nvim-treesitter.configs").setup({
  -- Install parsers for various languages
  ensure_installed = {
    "javascript",
    "typescript",
    "tsx",
    "json",
    "html",
    "css",
  }, -- Add more languages as needed

  -- Enable Treesitter-based syntax highlighting
  highlight = {
    enable = true, -- Enable Treesitter highlighting
    additional_vim_regex_highlighting = false, -- Disable Vim's regex-based highlighting
  },

  -- You can enable more Treesitter features as needed (optional)
  indent = { enable = true }, -- Enable Treesitter-based indentation (optional)
})

-- Show Minimap for all files by default
vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    vim.cmd("Minimap")
  end,
})

-- GitHub Copilot

-- Don't use tab, because we
-- vim.g.copilot_no_tab_map = true
-- ...actually, let's use tab

-- Sometimes, tab doesn't work, because it's used for other things. So, we'll
-- use <C-.> in addition to tab.
vim.api.nvim_set_keymap(
  "i",
  "<C-.>",
  'copilot#Accept("<CR>")',
  { silent = true, expr = true }
)
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

-- Define subtle colors for the rainbow delimiters
-- highlight RainbowDelimiterBlue guifg=#5F9EA0  -- Cadet Blue
-- highlight RainbowDelimiterGreen guifg=#8FBC8F  -- Dark Sea Green
-- highlight RainbowDelimiterCyan guifg=#7AC5CD   -- Medium Aquamarine
-- highlight RainbowDelimiterGray guifg=#A9A9A9   -- Dark Gray
-- highlight RainbowDelimiterViolet guifg=#9370DB -- Medium Purple
-- highlight RainbowDelimiterLightBlue guifg=#ADD8E6 -- Light Blue
-- highlight RainbowDelimiterLightGray guifg=#D3D3D3 -- Light Gray
vim.cmd([[
  highlight RainbowDelimiterBlue guifg=#5F9EA0
  highlight RainbowDelimiterGreen guifg=#8FBC8F
  highlight RainbowDelimiterCyan guifg=#7AC5CD
  highlight RainbowDelimiterGray guifg=#A9A9A9
  highlight RainbowDelimiterViolet guifg=#9370DB
  highlight RainbowDelimiterLightBlue guifg=#ADD8E6
  highlight RainbowDelimiterLightGray guifg=#D3D3D3
]])

local rainbow_delimiters = require("rainbow-delimiters")

vim.g.rainbow_delimiters = {
  strategy = {
    [""] = rainbow_delimiters.strategy["global"],
    vim = rainbow_delimiters.strategy["local"],
  },
  query = {
    [""] = "rainbow-delimiters",
    lua = "rainbow-blocks",
  },
  highlight = {
    "RainbowDelimiterBlue",
    "RainbowDelimiterGreen",
    "RainbowDelimiterCyan",
    "RainbowDelimiterGray",
    "RainbowDelimiterViolet",
    "RainbowDelimiterLightBlue",
    "RainbowDelimiterLightGray",
  },
}

require("lualine").setup({
  options = {
    theme = "onedark", -- You can change this to your preferred color scheme
    section_separators = { "▶️", "◀️" }, -- Use arrow emojis as section separators
    component_separators = { "|", "|" }, -- Use simple vertical bars as component separators
    disabled_filetypes = {}, -- Disable for specific filetypes if needed
  },
  sections = {
    lualine_a = { "mode" }, -- Shows the current mode (e.g., Insert, Normal, etc.)
    -- lualine_b = { "branch" },
    lualine_b = {},
    lualine_c = {
      { "filename" }, -- Shows the current file name
      {
        "diagnostics",
        sources = { "nvim_lsp" },
        sections = { "error", "warn", "info", "hint" },
        diagnostics_color = {
          error = { fg = "#ff6c6b" }, -- Error color (red)
          warn = { fg = "#ECBE7B" }, -- Warning color (yellow)
          info = { fg = "#51afef" }, -- Info color (blue)
          hint = { fg = "#98be65" }, -- Hint color (green)
        },
        symbols = {
          error = "❌ ", -- Red square for errors
          warn = "⚠️ ", -- Orange square for warnings
          info = "ℹ️ ", -- Blue square for info
          hint = "💡 ", -- Lightbulb for hints
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

-- Custom tabline function to display all window names in each tab
function MyTabline()
  local s = ""
  local tabpages = vim.api.nvim_list_tabpages()
  local current_tabpage = vim.api.nvim_get_current_tabpage()

  -- Loop through each tab
  for _, tabpage in ipairs(tabpages) do
    local windows = vim.api.nvim_tabpage_list_wins(tabpage) -- Get all windows in the tab
    local tab_str = ""

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
        or "[No Name]"
      local folders = vim.split(vim.fn.fnamemodify(full_path, ":h"), "/")
      for _, folder in ipairs(folders) do
        if folder ~= "" then
          path_letters = path_letters .. folder:sub(1, 1) .. "/"
        end
      end

      -- Build the diagnostic string (only show non-zero counts)
      local diagnostic_str = ""
      if diagnostic.error > 0 then
        diagnostic_str = diagnostic_str .. " ❌ " .. diagnostic.error
      end
      if diagnostic.warn > 0 then
        diagnostic_str = diagnostic_str .. " ⚠️ " .. diagnostic.warn
      end
      -- if diagnostic.info > 0 then
      --   diagnostic_str = diagnostic_str .. " ℹ️ " .. diagnostic.info
      -- end
      -- if diagnostic.hint > 0 then
      --   diagnostic_str = diagnostic_str .. " 💡 " .. diagnostic.hint
      -- end

      -- Append the buffer name and diagnostics to the tab string
      if not string.find(bufname, "-MINIMAP-") then -- Exclude Minimap buffers if present
        tab_str = " "
          .. tab_str
          .. path_letters
          .. bufname
          .. diagnostic_str
          .. modified
          .. " | "
      end
    end

    -- Remove trailing " | " from the last window in the tab
    tab_str = tab_str:sub(1, -4)

    -- Highlight the current tab
    if tabpage == current_tabpage then
      s = s .. "%#TabLineSel#" .. tab_str .. " %#TabLine#"
    else
      s = s .. "%#TabLine#" .. tab_str .. " "
    end
  end

  return s
end

-- Set the custom tabline
vim.o.tabline = "%!v:lua.MyTabline()"

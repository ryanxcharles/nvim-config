-- ~/.config/nvim/init.lua
require('packer').startup(function()
  use 'wbthomason/packer.nvim' -- Packer manages itself
  use 'nvim-telescope/telescope.nvim' -- Telescope
  use 'nvim-lua/plenary.nvim' -- Required by telescope
  use 'wfxr/minimap.vim' -- Use ":Minimap"
  use 'neovim/nvim-lspconfig' -- language server for typescript, etc.

  -- a series of auto-complete related plugins
  use 'hrsh7th/nvim-cmp'          -- Autocompletion plugin
  use 'hrsh7th/cmp-nvim-lsp'      -- LSP source for nvim-cmp
  use 'hrsh7th/cmp-buffer'        -- Buffer source for nvim-cmp
  use 'hrsh7th/cmp-path'          -- Path source for nvim-cmp
  use 'hrsh7th/cmp-cmdline'       -- Command line completion
  use 'saadparwaiz1/cmp_luasnip'  -- Snippet completion
  use 'L3MON4D3/LuaSnip'          -- Snippet engine

  -- code formatting (e.g., using biome)
  use 'mhartington/formatter.nvim'

  -- colorizer for HTML/CSS (but not Tailwind)
  use 'norcalli/nvim-colorizer.lua'

  -- colors for Tailwind
  use 'themaxmarchuk/tailwindcss-colors.nvim'

  -- accurate syntax highlighting for typescript
  use 'nvim-treesitter/nvim-treesitter'

end)

-- Set space as the leader key
vim.g.mapleader = " "

local opts = { noremap = true, silent = true }

-- Enable 24-bit RGB color in the terminal
vim.opt.termguicolors = true

-- Key mappings using leader key
vim.api.nvim_set_keymap('n', '<leader>w', ':w<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>h', 'gT', opts)
vim.api.nvim_set_keymap('n', '<leader>l', 'gt', opts)
vim.api.nvim_set_keymap('n', '<leader>n', ':tabnew<CR>:e ', opts)
vim.api.nvim_set_keymap('n', '<leader>q', ':q<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>e', ':e ', opts)

-- Window navigation
vim.api.nvim_set_keymap('n', ';h', ':wincmd h<CR>', opts)
vim.api.nvim_set_keymap('n', ';l', ':wincmd l<CR>', opts)
vim.api.nvim_set_keymap('n', ';k', ':wincmd k<CR>', opts)
vim.api.nvim_set_keymap('n', ';j', ':wincmd j<CR>', opts)

-- Redraw screen
vim.api.nvim_set_keymap('n', '<leader>.', '<C-l>', opts)

-- Key binding to use Telescope to search files
-- Set up keybinding to always show hidden files
vim.api.nvim_set_keymap('n', '<leader>p', ":lua require('telescope.builtin').find_files({ hidden = true })<CR>", { noremap = true, silent = true })
-- Telscope search inside files with ripgrep (rg)
vim.api.nvim_set_keymap('n', '<leader>fg', ':Telescope live_grep<CR>', { noremap = true, silent = true })

-- LSP integration with Telescope for TypeScript
vim.api.nvim_set_keymap('n', '<leader>fs', '<cmd>Telescope lsp_document_symbols<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>fr', '<cmd>Telescope lsp_references<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>fd', '<cmd>Telescope diagnostics<CR>', { noremap = true, silent = true })
-- Space + fs: Search document symbols (like variables, functions, etc.).
-- Space + fr: Find all references to a symbol.
-- Space + fd: Search through diagnostics (errors, warnings).

require('telescope').setup{
  defaults = {
    vimgrep_arguments = {
      'rg',          -- Ripgrep binary
      '--color=never',
      '--no-heading',
      '--with-filename',
      '--line-number',
      '--column',
      '--smart-case'
    },
    -- Other default settings
  }
}

-- Key bindind to reload init.lua file
vim.api.nvim_set_keymap('n', '<leader>r', ':luafile ~/.config/nvim/init.lua<CR>', { noremap = true, silent = true })

-- two spaces for typescript/javascript/lua
vim.api.nvim_create_autocmd("FileType", {
  pattern = {"javascript", "typescript", "javascriptreact", "typescriptreact", "lua"},
  callback = function()
    vim.bo.tabstop = 2        -- Number of spaces for a tab
    vim.bo.shiftwidth = 2     -- Number of spaces for auto-indent
    vim.bo.expandtab = true   -- Use spaces instead of tabs
  end,
})


-- TypeScript organize inputs
vim.api.nvim_set_keymap('n', '<leader>oi', '<cmd>lua vim.lsp.buf.code_action({ context = { only = { "source.organizeImports" } }, apply = true })<CR>', { noremap = true, silent = true })

-- Import the LSP config plugin
local lspconfig = require('lspconfig')

-- TypeScript Language Server setup
lspconfig.ts_ls.setup {
  -- This function attaches common settings when the LSP attaches to a buffer
  on_attach = function(client, bufnr)
    -- Optionally, disable tsserver's formatting in favor of something like prettier
    client.server_capabilities.documentFormattingProvider = false

    -- Add keybindings for common LSP features
    local opts = { noremap = true, silent = true }

    -- Go to definition
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)

    -- Hover documentation
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)

    -- Find references
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)

    -- Go to implementation
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)

    -- Rename symbol
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)

    -- Code actions
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  end,

  -- Ensure the server uses the right config for each project directory
  root_dir = lspconfig.util.root_pattern('tsconfig.json'),

  -- Add additional configuration options if needed (e.g., filetypes)
  filetypes = { "typescript", "typescriptreact", "typescript.tsx" },

  -- Command to launch the TypeScript Language Server via the global `pnpm` path
  cmd = { "typescript-language-server", "--stdio" },

  -- Add capabilities for autocompletion
  capabilities = require('cmp_nvim_lsp').default_capabilities(),
}

-- Set up nvim-cmp (auto-complete)
local cmp = require'cmp'

cmp.setup({
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
    end,
  },
  mapping = {
    ['<C-Space>'] = cmp.mapping.complete(),    -- Trigger completion manually
    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Confirm selection
    ['<Tab>'] = cmp.mapping.select_next_item(), -- Navigate completion with Tab
    ['<S-Tab>'] = cmp.mapping.select_prev_item(),
  },
  sources = {
    { name = 'nvim_lsp' },    -- LSP completions (TypeScript, etc.)
    { name = 'buffer' },      -- Completions from current buffer
    { name = 'path' },        -- Path completions
    { name = 'luasnip' },     -- Snippet completions
  }
})

require('formatter').setup({
  filetype = {
    typescript = {
      function()
        return {
          exe = "biome",  -- The Biome executable
          args = {"format", "--stdin-file-path", vim.api.nvim_buf_get_name(0), "--write"},
          stdin = true,
        }
      end,
    },
    typescriptreact = {
      function()
        return {
          exe = "biome",  -- The Biome executable
          args = {"format", "--stdin-file-path", vim.api.nvim_buf_get_name(0), "--write"},
          stdin = true,
        }
      end,
    },
    javascript = {
      function()
        return {
          exe = "biome",
          args = {"format", "--stdin-file-path", vim.api.nvim_buf_get_name(0), "--write"},
          stdin = true,
        }
      end,
    },
    javascriptreact = {
      -- Same for JavaScript files
      function()
        return {
          exe = "biome",
          args = {"format", "--stdin-file-path", vim.api.nvim_buf_get_name(0), "--write"},
          stdin = true,
        }
      end,
    },
  }
})

-- TailwindCSS Language Server setup
lspconfig.tailwindcss.setup{
  on_attach = function(client, bufnr)
    -- Any additional LSP settings or keybindings you want for Tailwind
    require("tailwindcss-colors").buf_attach(bufnr)
  end,
  filetypes = { "html", "javascriptreact", "typescriptreact", "css" }, -- Add any other file types where you use Tailwind
}

-- TailwindCSS colors
require('tailwindcss-colors').setup()

-- Enable colorizer for CSS, HTML, JavaScript, and more, but not Tailwind
require('colorizer').setup({
  'css',
  'javascript',
  'javascriptreact',
  'typescriptreact',
  'html',
}, {
  RGB      = true;         -- #RGB hex codes
  RRGGBB   = true;         -- #RRGGBB hex codes
  names    = false;        -- Disable color names like "Red"
  RRGGBBAA = true;         -- #RRGGBBAA hex codes
  rgb_fn   = true;         -- Enable rgb() and rgba() functions
  hsl_fn   = true;         -- Enable hsl() and hsla() functions
  css      = true;         -- Enable all CSS features: rgb_fn, hsl_fn, names, hex codes
  css_fn   = true;         -- Enable all CSS *functions*: rgb_fn, hsl_fn
})

-- Accurate syntax highlighting for typescript
require'nvim-treesitter.configs'.setup {
  -- Install parsers for various languages
  ensure_installed = { "javascript", "typescript", "tsx", "json", "html", "css" }, -- Add more languages as needed

  -- Enable Treesitter-based syntax highlighting
  highlight = {
    enable = true,              -- Enable Treesitter highlighting
    additional_vim_regex_highlighting = false, -- Disable Vim's regex-based highlighting
  },

  -- You can enable more Treesitter features as needed (optional)
  indent = { enable = true },   -- Enable Treesitter-based indentation (optional)
}

-- Show Minimap for all files by default
vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    vim.cmd("Minimap")
  end,
})


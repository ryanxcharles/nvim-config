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

  -- colorizer for tailwind
  use 'norcalli/nvim-colorizer.lua'
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

-- Import the LSP config plugin
local lspconfig = require('lspconfig')

-- TypeScript Language Server setup
lspconfig.ts_ls.setup {
  -- This function attaches common settings when the LSP attaches to a buffer
  on_attach = function(client, bufnr)
    -- Optionally, disable tsserver's formatting in favor of something like prettier
    client.server_capabilities.documentFormattingProvider = false
  end,

  -- Ensure the server uses the right config for each project directory
  root_dir = lspconfig.util.root_pattern('tsconfig.json'),

  -- Add additional configuration options if needed (e.g., filetypes)
  filetypes = { "typescript", "typescriptreact", "typescript.tsx" },

  -- Command to launch the TypeScript Language Server via the global `pnpm` path
  cmd = { "typescript-language-server", "--stdio" },
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

-- Ensure TypeScript server is integrated with nvim-cmp
local capabilities = require('cmp_nvim_lsp').default_capabilities()

require('lspconfig').ts_ls.setup {
  capabilities = capabilities,
  on_attach = function(client, bufnr)
    -- Optional: Disable tsserver formatting if using another formatter like Prettier
    client.server_capabilities.documentFormattingProvider = false
  end,
}

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
  end,
  filetypes = { "html", "javascriptreact", "typescriptreact", "css" }, -- Add any other file types where you use Tailwind
}

-- Enable colorizer for CSS, HTML, JavaScript, and more
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


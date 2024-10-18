-- Import the LSP config plugin
local lspconfig = require("lspconfig")
local opts = { noremap = true, silent = true }

-- lua: Set up the Lua Language Server first (because lua is used by nvim -
-- seems logical)
require("lspconfig").lua_ls.setup({
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using (LuaJIT for Neovim)
        version = "LuaJIT",
        path = vim.split(package.path, ";"),
      },
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = { "vim", "use" },
      },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false, -- Set this to true if using third-party libraries
      },
      telemetry = {
        enable = false,
      },
    },
  },
})

-- We are going to set up TypeScript for node.js, and deno separately

-- Deno TypeScript LSP setup
lspconfig.denols.setup({
  root_dir = lspconfig.util.root_pattern("deno.json", "deno.jsonc"), -- Use deno.json to detect project root
  init_options = {
    enable = true,
    lint = true,
    unstable = true, -- Enable unstable features if needed
  },
  -- Add additional configuration options if needed (e.g., filetypes)
  filetypes = { "typescript", "typescriptreact", "tsx", "json", "jsonc" },
  on_attach = function(client)
    print("Deno LSP attached!")
    -- vim.api.nvim_buf_create_user_command(bufnr, "Format", function()
    --   vim.lsp.buf.format({ async = true })
    -- end, { desc = "Format current buffer with Deno" })
  end,
})

-- TypeScript Language Server setup for node.js
lspconfig.ts_ls.setup({
  -- This function attaches common settings when the LSP attaches to a buffer
  on_attach = function(client, bufnr)
    -- Optionally, disable tsserver's formatting in favor of something like prettier
    client.server_capabilities.documentFormattingProvider = false

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
      "<Leader>rn",
      "<cmd>lua vim.lsp.buf.rename()<CR>",
      opts
    )

    -- Code actions
    vim.api.nvim_buf_set_keymap(
      bufnr,
      "n",
      "<Leader>ca",
      "<cmd>lua vim.lsp.buf.code_action()<CR>",
      opts
    )

    -- Shortcut to organize imports
    vim.api.nvim_set_keymap(
      "n",
      "<Leader>oi",
      '<cmd>lua vim.lsp.buf.code_action({ context = { only = { "source.organizeImports" } }, apply = true })<CR>',
      opts
    )
  end,

  -- Ensure the server uses the right config for each project directory
  root_dir = function(fname)
    return lspconfig.util.root_pattern("package.json", "tsconfig.json")(fname)
  end,

  -- single-file must be disabled to not conflict with Deno
  single_file_support = false,

  -- Add additional configuration options if needed (e.g., filetypes)
  filetypes = { "typescript", "typescriptreact", "typescript.tsx" },

  -- Command to launch the TypeScript Language Server via the global `pnpm` path
  cmd = { "typescript-language-server", "--stdio" },

  settings = {
    -- Add TypeScript-specific settings
    typescript = {
      -- Enable the ts language server for JavaScript files
      preferences = {
        tsserver = {
          exclude = { "**/node_modules/**" },
        },
      },
    },
  },

  -- Add capabilities for autocompletion
  capabilities = require("cmp_nvim_lsp").default_capabilities(),
})

-- Import the LSP config plugin
local lspconfig = require("lspconfig")

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

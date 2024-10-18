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

-- Import the LSP config plugin
local lspconfig = require("lspconfig")

-- lua: Set up the Lua Language Server first (because lua is used by nvim -
-- seems logical)
lspconfig.lua_ls.setup({
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using (LuaJIT for Neovim)
        version = "LuaJIT",
        -- Set the path to Lua modules (optional, helps with module resolution)
        path = vim.split(package.path, ";"),
      },
      diagnostics = {
        -- Recognize the `vim` global to avoid "undefined global" warnings
        globals = { "vim" }, -- Removed "use" unless you specifically need it for another global
      },
      workspace = {
        -- Make the server aware of Neovim runtime files for API recognition
        library = vim.api.nvim_get_runtime_file("", true),
        -- Optionally, disable third-party library checks to avoid prompts
        checkThirdParty = false,
        -- Preload Neovim-specific files or directories (optional, can be tuned)
        preloadFileSize = 1000, -- Increase if needed for larger runtime files
      },
      -- Enable completion for Neovim APIs
      completion = {
        callSnippet = "Replace", -- Show function call snippets in completion
      },
      -- Disable telemetry for privacy
      telemetry = {
        enable = false,
      },
      -- Hinting for better inline feedback (optional)
      hint = {
        enable = true, -- Show parameter hints and other inline info
      },
    },
  },
})

-- We are going to set up TypeScript for node.js, and deno separately

-- deno: Deno TypeScript LSP setup
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
    -- print("Deno LSP attached!")
    -- vim.api.nvim_buf_create_user_command(bufnr, "Format", function()
    --   vim.lsp.buf.format({ async = true })
    -- end, { desc = "Format current buffer with Deno" })
  end,
})

-- typescript: TypeScript Language Server setup for node.js
lspconfig.ts_ls.setup({
  -- This function attaches common settings when the LSP attaches to a buffer
  on_attach = function(client, bufnr)
    -- print("Typescript LSP attached!")
    -- Optionally, disable tsserver's formatting in favor of something like prettier
    client.server_capabilities.documentFormattingProvider = false
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

lspconfig.biome.setup({
  on_attach = function(client, bufnr)
    -- Format on save (disabled for now)
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

lspconfig.tailwindcss.setup({
  on_attach = function(client, bufnr)
    -- Add any additional LSP settings or keybindings for Tailwind here
  end,
  filetypes = { "html", "javascriptreact", "typescriptreact", "css" }, -- Add other file types where you use Tailwind
})

-- first install wgsl-analyzer
-- cargo install --git https://github.com/wgsl-analyzer/wgsl-analyzer.git wgsl_analyzer
lspconfig.wgsl_analyzer.setup({})

-- Function to find the virtual environment Python interpreter
local function find_venv_python()
  local cwd = vim.fn.getcwd()
  local venv_path = cwd .. "/.venv"

  -- Check if .venv exists in the project root
  if vim.fn.isdirectory(venv_path) == 1 then
    -- On Unix-like systems, the interpreter is typically in .venv/bin/python
    local python_path = venv_path .. "/bin/python"
    if vim.fn.executable(python_path) == 1 then
      return python_path
    end

    -- On Windows, it might be in .venv/Scripts/python.exe
    python_path = venv_path .. "/Scripts/python.exe"
    if vim.fn.executable(python_path) == 1 then
      return python_path
    end
  end

  -- Fallback to system Python if no virtual environment is found
  return vim.fn.exepath("python3")
end

-- Python: PyRight LSP Setup
lspconfig.pyright.setup({
  settings = {
    pyright = {
      -- Enable type checking
      typeCheckingMode = "basic", -- Options: "off", "basic", "strict"
    },
    python = {
      pythonPath = find_venv_python(), -- Dynamically set the Python path
    },
    on_init = function(client)
      -- Optionally, update pythonPath dynamically when initializing the LSP client
      client.config.settings.python.pythonPath = find_venv_python()
      client.notify(
        "workspace/didChangeConfiguration",
        { settings = client.config.settings }
      )
    end,
  },
})

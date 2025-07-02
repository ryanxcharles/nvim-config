-- # Ryan X. Charles NVim Configuration
--
-- The following tools must be installed to use this configuration:
-- - nvim v0.10.1+ (Neovim)
-- - git v2.33.0+ (for git integration)
-- - ripgrip v14.1.1 (for Telescope)
-- - stylua v0.20.0 (for Lua formatting)
-- - biome v1.9.2 (for TypeScript formatting)
-- - deno v2.0.0 (for Deno TypeScript LSP)
-- - prettier (for Markdown formatting)
-- - Nerdfonts (for icons)
-- - tailwindcss-language-server (for Tailwind CSS completions and colors)
-- - typescript-language-server (for TypeScript completions and diagnostics)
-- - rust/cargo (for Rust tools)
-- - lua-language-server (for Lua completions and diagnostics)
-- - wgsl-analyzer (for WebGPU Shading Language diagnostics)
-- - pyright (Python language server)
-- - topiary (with special nushell plugin for nushell support) (formatting nushell)
-- - dprint (for formatting Markdown)

-- TODO:
-- [ ] replace formatter with null-ls
-- [ ] Add Gitsigns (lewis6991/gitsigns.nvim)
-- [ ] Add markdown-preview.nvim (iamcco/markdown-preview.nvim)
-- [ ] replace rainbow-delimiters with nvim-ts-rainbow (p00f/nvim-ts-rainbow)

-- ## LazyVim configuration

-- ~/.config/nvim/init.lua
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- Telescope for finding files and grepping
  {
    "nvim-telescope/telescope.nvim",
    requires = { { "nvim-lua/plenary.nvim" } },
    config = function()
      require("telescope").setup({
        defaults = {
          file_ignore_patterns = { "node_modules" }, -- Exclude node_modules from typeahead matching
          vimgrep_arguments = {
            "rg", -- Ripgrep binary
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
            "--hidden", -- Search hidden files, because we use .server and .client
            "--glob",
            "!**/.git/**", -- Exclude the .git folder
          },
          -- Other default settings
        },
      })
    end,
  },

  -- LSP: For all language servers
  {
    "neovim/nvim-lspconfig",
    config = function()
      -- LSP configuration goes here
      -- Import the LSP config plugin
      local lspconfig = require("lspconfig")

      vim.lsp.enable("nushell")
      lspconfig.nushell.setup({
        cmd = { "nu", "--lsp" },
        filetypes = { "nu" },
        -- root_dir = function(bufnr, on_dir)
        --   on_dir(
        --     vim.fs.root(bufnr, { ".git" })
        --       or vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))
        --   )
        -- end,
      })
      -- lspconfig.nushell = {
      --   default_config = {
      --     cmd = { "nu", "--lsp" },
      --     filetypes = { "nu" },
      --     root_dir = function(fname)
      --       return lspconfig.util.find_git_ancestor(fname) or vim.fn.getcwd()
      --     end,
      --     settings = {},
      --   },
      -- }
      -- -- Setup Nushell LSP
      -- lspconfig.nushell.setup {
      --   on_attach = function(client, bufnr)
      --     print("Nushell LSP attached to buffer " .. bufnr)
      --     local opts = { buffer = bufnr, noremap = true, silent = true }
      --     vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
      --     vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
      --     vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
      --   end,
      -- }

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
          return lspconfig.util.root_pattern("package.json", "tsconfig.json")(
            fname
          )
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

      lspconfig.pyright.setup({
        root_dir = lspconfig.util.root_pattern(
          "pyproject.toml",
          "setup.py",
          "requirements.txt"
        ),
        on_new_config = function(new_config, root_dir)
          -- Dynamically set pythonPath based on the root_dir
          local python_path = nil
          if root_dir then
            local venv_paths = {
              root_dir .. "/.venv/bin/python",
              root_dir .. "/venv/bin/python",
            }
            for _, path in ipairs(venv_paths) do
              if vim.fn.executable(path) == 1 then
                python_path = path
                break
              end
            end
          end
          -- Fallback to system Python if no venv is found
          if not python_path then
            python_path = vim.fn.exepath("python3")
              or vim.fn.exepath("python")
              or "python"
          end
          -- Update the settings with the computed pythonPath
          new_config.settings.python.pythonPath = python_path
        end,
        settings = {
          python = {
            analysis = {
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              diagnosticMode = "openFilesOnly",
            },
          },
          pyright = {
            typeCheckingMode = "basic",
          },
        },
      })
    end,
  },

  -- Tailwind CSS colorizer
  {
    "roobert/tailwindcss-colorizer-cmp.nvim",
    config = function()
      require("tailwindcss-colorizer-cmp").setup({
        color_square_width = 2,
      })
    end,
  },

  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "roobert/tailwindcss-colorizer-cmp.nvim",
    },
    config = function()
      local cmp = require("cmp")
      local tailwind_colorizer = require("tailwindcss-colorizer-cmp").formatter

      cmp.setup({
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body) -- For Luasnip users.
          end,
        },
        mapping = {
          ["<C-Space>"] = cmp.mapping.complete(), -- Manually trigger completion
          ["<CR>"] = cmp.mapping.confirm({ select = false }), -- Confirm the first suggestion
          ["<Down>"] = cmp.mapping.select_next_item(), -- Navigate to next item
          ["<Up>"] = cmp.mapping.select_prev_item(), -- Navigate to previous item
          ["<C-e>"] = cmp.mapping.abort(), -- Close the completion window
        },
        sources = cmp.config.sources({
          { name = "nvim_lsp" }, -- LSP completions
          -- { name = "buffer" }, -- Buffer completions
          { name = "path" }, -- Path completions
          { name = "luasnip" }, -- Snippet completions
        }),
        formatting = {
          fields = { "abbr", "kind", "menu" },
          expandable_indicator = true,
          format = function(entry, item)
            item = tailwind_colorizer(entry, item)
            item.menu = ({
              nvim_lsp = "[LSP]",
              buffer = "[Buffer]",
              path = "[Path]",
              luasnip = "[Snippet]",
            })[entry.source.name]
            return item
          end,
        },
      })

      -- Set up cmdline completion
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = "path" },
          { name = "cmdline" },
        },
      })
    end,
  },

  -- Autocompletion plugin
  { "hrsh7th/cmp-nvim-lsp" }, -- LSP source for nvim-cmp
  { "hrsh7th/cmp-buffer" }, -- Buffer source for nvim-cmp
  { "hrsh7th/cmp-path" }, -- Path source for nvim-cmp
  { "hrsh7th/cmp-cmdline" }, -- Command line completion
  { "saadparwaiz1/cmp_luasnip" }, -- Snippet completion
  { "L3MON4D3/LuaSnip" }, -- Snippet engine

  -- GitHub Copilot (vimscript)
  {
    "github/copilot.vim",
    config = function()
      -- Vim sets .env files to filetype "sh" by default, but we don't want to
      -- disable copilot for .sh files, just .env. so we rename .env files to
      -- have filetype "env". Then we disable copilot for that filetype.
      vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
        pattern = "*.env",
        callback = function()
          vim.bo.filetype = "env"
        end,
      })
      vim.g.copilot_filetypes = {
        ["*"] = true, -- Enable for all filetypes
        env = false, -- Disable for .env files
      }
    end,
  },

  -- Copilot Chat
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      { "github/copilot.vim" }, -- or zbirenbaum/copilot.lua
      -- { "zbirenbaum/copilot.lua" },
      { "nvim-lua/plenary.nvim", branch = "master" }, -- for curl, log and async functions
    },
    build = "make tiktoken", -- Only on MacOS or Linux
    opts = {
      -- See Configuration section for options
      -- Testing autocomp
    },
    -- See Commands section for default commands if you want to lazy load on them
  },

  -- Treesitter for syntax highlighting and text-objects for selecting markdown code blocks
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
    run = ":TSUpdate",
    config = function()
      ---@diagnostic disable-next-line: missing-fields
      require("nvim-treesitter.configs").setup({
        -- Install parsers for various languages
        ensure_installed = {
          "css",
          "html",
          "javascript",
          "jsdoc",
          "json",
          "jsonc",
          "lua",
          "markdown",
          "markdown_inline",
          "nu",
          "python",
          "rust",
          "toml",
          "tsx",
          "typescript",
          "wgsl",
          "yaml",
          -- "zsh",
          "bash",
        }, -- Add more languages as needed

        -- Enable Treesitter-based syntax highlighting
        highlight = {
          enable = true, -- Enable Treesitter highlighting
          additional_vim_regex_highlighting = false, -- Disable Vim's regex-based highlighting
        },

        -- You can enable more Treesitter features as needed (optional)
        indent = { enable = false }, -- Enable Treesitter-based indentation (optional)

        -- Folding
        fold = { enable = true }, -- Enable Treesitter-based folding (optional)

        -- Required for nvim-treesitter-textobjects
        textobjects = {
          select = {
            enable = true,
            lookahead = true, -- Automatically jump forward to textobj if cursor is outside
            keymaps = {
              -- Define a custom text object for markdown fenced code blocks
              ["ic"] = {
                query = "@codeblock.inner",
                desc = "Select inside markdown code block",
              },
              ["ac"] = {
                query = "@codeblock.outer",
                desc = "Select around markdown code block",
              },
              ["if"] = {
                query = "@function.inner",
                desc = "Select inside function (TypeScript, etc.)",
              },
              ["af"] = {
                query = "@function.outer",
                desc = "Select around function (TypeScript, etc.)",
              },
              ["ik"] = {
                query = "@class.inner",
                desc = "Select inside class (TypeScript, etc.)",
              },
              ["ak"] = {
                query = "@class.outer",
                desc = "Select around class (TypeScript, etc.)",
              },
            },
            -- Optionally, configure selection modes or other settings
            selection_modes = {
              ["@codeblock.inner"] = "V", -- Use linewise visual mode for inner selection
              ["@codeblock.outer"] = "V", -- Use linewise visual mode for outer selection
              ["@function.inner"] = "V",
              ["@function.outer"] = "V",
              ["@class.inner"] = "V",
              ["@class.outer"] = "V",
            },
          },
          move = {
            enable = true,
            set_jumps = true, -- Add to jump list for navigation history
            goto_next_start = {
              ["]c"] = {
                query = "@codeblock.outer",
                desc = "Next code block start",
              },
              ["]f"] = {
                query = "@function.outer",
                desc = "Next function start",
              },
              ["]k"] = { query = "@class.outer", desc = "Next class start" },
            },
            goto_next_end = {
              ["]C"] = {
                query = "@codeblock.outer",
                desc = "Next code block end",
              },
            },
            goto_previous_start = {
              ["[c"] = {
                query = "@codeblock.outer",
                desc = "Previous code block start",
              },
              ["[f"] = {
                query = "@function.outer",
                desc = "Previous function start",
              },
              ["[k"] = { query = "@class.outer", desc = "Previous class start" },
            },
            goto_previous_end = {
              ["[C"] = {
                query = "@codeblock.outer",
                desc = "Previous code block end",
              },
            },
          },
        },
      })

      -- Define the custom Tree-sitter queries for markdown code blocks
      vim.treesitter.query.set(
        "markdown",
        "textobjects",
        [[
      (fenced_code_block
        (code_fence_content) @codeblock.inner
      ) @codeblock.outer
    ]]
      )

      -- Enable Treesitter folding globally
      vim.opt.foldmethod = "expr"
      vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
      vim.opt.foldenable = true
      vim.opt.foldlevelstart = 99 -- Start with all folds open

      -- Alias zsh to bash for Markdown code blocks
      vim.treesitter.language.register("bash", "zsh")
    end,
  },

  {
    "stevearc/conform.nvim",
    config = function()
      -- Function to search for a file (filename) in the directory of another file (full_path)
      -- and recursively in its parent directories.
      local function find_file_in_file_parents(filename, full_path)
        -- Get the directory of the file passed in as full_path
        local dir = vim.fn.fnamemodify(full_path, ":h") -- ":h" extracts the directory from full_path
        --print("Starting search in directory: " .. dir)

        while dir do
          local filepath = dir .. "/" .. filename
          --print("Checking for file at: " .. filepath) -- Debug print

          local stat = vim.loop.fs_stat(filepath)
          if stat then
            print("File found: " .. filepath) -- Debug print when file is found
            return filepath -- Return the absolute file path if found
          end

          -- Move to the parent directory
          local parent = dir:match("(.*/)[^/]+/?$")
          if not parent or parent == dir then
            --print("Reached root directory, stopping search.") -- Debug print
            break -- Reached the root directory
          end

          --print("Moving to parent directory: " .. parent) -- Debug print for parent
          dir = parent
        end

        print("File not found.") -- Debug print when file is not found
        return nil -- File not found
      end
      require("conform").setup({
        formatters_by_ft = {
          markdown = { "dprint" },
          toml = { "dprint" },
          typescript = { "biome" },
          typescriptreact = { "biome" },
          javascript = { "biome" },
          javascriptreact = { "biome" },
          json = { "biome" },
          jsonc = { "biome" },
          lua = { "stylua" },
          rust = { "rustfmt" },
          python = { "black" },
          nu = { "topiary" },
          wgsl = { "wgsl_analyzer" },
        },
        format_on_save = false,
        -- format_on_save = {
        --   timeout_ms = 500,
        --   lsp_fallback = true,
        -- },
        formatters = {
          biome = {
            command = "biome",
            args = function(self, ctx)
              local config_path = find_file_in_file_parents("biome.json", ctx.filename)
              return {
                "format",
                "--config-path",
                config_path,
                "--stdin-file-path",
                ctx.filename,
              }
            end,
            stdin = true,
          },
          dprint = {
            command = "dprint",
            args = function(self, ctx)
              return { "fmt", "--stdin", ctx.filename }
            end,
            stdin = true,
          },
          stylua = {
            command = "stylua",
            args = {
              "--indent-type",
              "Spaces",
              "--indent-width",
              "2",
              "--search-parent-directories",
              "-",
            },
            stdin = true,
          },
          rustfmt = {
            command = "rustfmt",
            args = { "--emit", "stdout" },
            stdin = true,
          },
          black = {
            command = "black",
            args = { "-" },
            stdin = true,
          },
          topiary = {
            command = "topiary",
            args = { "format", "--language", "nu" },
            stdin = true,
          },
          wgsl_analyzer = {
            command = "wgsl_analyzer",
            args = { "format" },
            stdin = true,
          },
        },
      })

      vim.api.nvim_create_user_command("Format", function(args)
        local range = nil
        if args.count ~= -1 then
          local end_line =
            vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
          range = {
            start = { args.line1, 0 },
            ["end"] = { args.line2, end_line:len() },
          }
        end
        require("conform").format({
          async = true,
          lsp_format = "fallback",
          range = range,
        })
      end, { range = true })
    end,
  },

  -- Colorizer for HTML/CSS
  {
    "NvChad/nvim-colorizer.lua",
    config = function()
      -- Enable colorizer for CSS, HTML, JavaScript, and more, but not Tailwind
      require("colorizer").setup({
        filetypes = {
          "html",
          "css",
          "javascript",
          "typescript",
          "javascriptreact",
          "typescriptreact",
          "lua",
          "tsx",
          -- "nu",
        },
        user_default_options = {
          RGB = true, -- #RGB hex codes
          RRGGBB = true, -- #RRGGBB hex codes
          names = true, -- "Name" codes like Blue or blue
          RRGGBBAA = false, -- #RRGGBBAA hex codes
          AARRGGBB = false, -- 0xAARRGGBB hex codes
          rgb_fn = false, -- CSS rgb() and rgba() functions
          hsl_fn = false, -- CSS hsl() and hsla() functions
          css = false, -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
          css_fn = false, -- Enable all CSS *functions*: rgb_fn, hsl_fn
          -- Available modes for `mode`: foreground, background,  virtualtext
          mode = "background", -- Set the display mode.
          -- True is same as normal
          -- tailwind = false, -- Disable tailwind colors (using tailwind-tools instead)
          tailwind = true,
          -- parsers can contain values used in |user_default_options|
          sass = { enable = false, parsers = { "css" } }, -- Enable sass colors
          virtualtext = "■",
          -- update color values even if buffer is not focused
          -- example use: cmp_menu, cmp_docs
          always_update = false,
        },
        -- all the sub-options of filetypes apply to buftypes
        buftypes = {},
      })
    end,
  },

  -- Rainbow delimiters <{[(
  {
    "HiPhish/rainbow-delimiters.nvim",
    config = function()
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
        whitelist = {
          "vim",
          "lua",
          "javascript",
          "typescript",
          "html",
          "css",
          "json",
          "markdown",
          "python",
          "rust",
          "c",
          "cpp",
        },
      }
    end,
  },

  -- Lualine for status line
  {
    "nvim-lualine/lualine.nvim",
    config = function()
      -- Define a custom theme for lualine
      -- local lualine_theme = {
      --   normal = {
      --     a = { fg = "#ffffff", bg = "#5f87af", gui = "bold" }, -- Blue-gray for normal mode
      --     b = { fg = "#ffffff", bg = "#3a3a3a" }, -- Dark background for section b
      --     c = { fg = "#ffffff", bg = "#14161b" }, -- Even darker for section c
      --   },
      --   insert = { a = { fg = "#ffffff", bg = "#87af5f", gui = "bold" } }, -- Green for insert mode
      --   visual = { a = { fg = "#ffffff", bg = "#d7af5f", gui = "bold" } }, -- Yellow for visual mode
      --   replace = { a = { fg = "#ffffff", bg = "#d75f5f", gui = "bold" } }, -- Red for replace mode
      --   command = { a = { fg = "#ffffff", bg = "#af5fff", gui = "bold" } }, -- Purple for command mode
      --   inactive = {
      --     a = { fg = "#bcbcbc", bg = "#3a3a3a", gui = "bold" }, -- Gray for inactive mode
      --     b = { fg = "#bcbcbc", bg = "#14161b" },
      --     c = { fg = "#bcbcbc", bg = "#14161b" },
      --   },
      -- }
      local catppuccin = require("catppuccin.palettes").get_palette() -- Get Catppuccin palette

      local lualine_theme = {
        normal = {
          a = { fg = catppuccin.base, bg = catppuccin.blue, gui = "bold" },
          b = { fg = catppuccin.text, bg = catppuccin.surface0 },
          c = { fg = catppuccin.text, bg = catppuccin.mantle },
        },
        insert = {
          a = { fg = catppuccin.base, bg = catppuccin.green, gui = "bold" },
        },
        visual = {
          a = { fg = catppuccin.base, bg = catppuccin.yellow, gui = "bold" },
        },
        replace = {
          a = { fg = catppuccin.base, bg = catppuccin.red, gui = "bold" },
        },
        command = {
          a = { fg = catppuccin.text, bg = catppuccin.purple, gui = "bold" },
        },
        inactive = {
          a = {
            fg = catppuccin.overlay0,
            bg = catppuccin.surface0,
            gui = "bold",
          },
          b = { fg = catppuccin.overlay0, bg = catppuccin.mantle },
          c = { fg = catppuccin.overlay0, bg = catppuccin.mantle },
        },
      }

      -- Customize the statusline with lualine
      require("lualine").setup({
        options = {
          theme = lualine_theme, -- Use our custom bright theme
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
    end,
  },

  -- Git integration
  {
    "tpope/vim-fugitive",
  },

  -- Markdown preview
  {
    "preservim/vim-markdown",
    dependencies = { "godlygeek/tabular" },
  },

  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim", -- Required dependency
      "nvim-tree/nvim-web-devicons", -- Optional dependency for file icons
      "MunifTanjim/nui.nvim", -- Required dependency for UI components
    },
    config = function()
      -- Neo-tree setup (neotree)
      require("neo-tree").setup({
        close_if_last_window = true, -- Closes Neo-tree if it's the last open window
        popup_border_style = "rounded", -- Rounded border for popups
        enable_git_status = true, -- Show git status icons
        enable_diagnostics = true, -- Show LSP diagnostics in the file tree
        filesystem = {
          -- follow_current_file = true, -- Automatically focus on the current file
          use_libuv_file_watcher = true, -- Automatically refresh the tree when files change
          filtered_items = {
            hide_dotfiles = false,
          },
        },
        buffers = {
          -- follow_current_file = true, -- Automatically focus on the current buffer
        },
        git_status = {
          window = {
            position = "float", -- Open a floating window for git status
          },
        },
      })
    end,
  },

  -- Dressing - better input boxes
  {
    "stevearc/dressing.nvim",
  },

  -- Better comment/uncomment
  {
    "tpope/vim-commentary",
  },

  -- surround.vim - Surround text objects
  {
    "tpope/vim-surround",
  },

  -- alpha-nvim greeter (splash screen)
  {
    "goolord/alpha-nvim",
    dependencies = {
      "echasnovski/mini.icons",
    },
    config = function()
      require("alpha").setup(require("alpha.themes.startify").opts)
    end,
  },

  {
    "nvimtools/none-ls.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
  },

  {
    "simrat39/rust-tools.nvim",
    dependencies = { "neovim/nvim-lspconfig" },
    config = function()
      local rust_tools = require("rust-tools")

      local opts = { noremap = true, silent = true }

      -- rust: Rust tools setup with rust-analyzer
      rust_tools.setup({
        server = {
          on_attach = function(client, bufnr)
            -- Keybindings for LSP features in Rust files
            vim.api.nvim_buf_set_keymap(
              bufnr,
              "n",
              "gd",
              "<cmd>lua vim.lsp.buf.definition()<CR>",
              opts
            )
            vim.api.nvim_buf_set_keymap(
              bufnr,
              "n",
              "K",
              "<cmd>lua vim.lsp.buf.hover()<CR>",
              opts
            )
            vim.api.nvim_buf_set_keymap(
              bufnr,
              "n",
              "<Leader>ca",
              "<cmd>lua vim.lsp.buf.code_action()<CR>",
              opts
            )
            vim.api.nvim_buf_set_keymap(
              bufnr,
              "n",
              "<Leader>rn",
              "<cmd>lua vim.lsp.buf.rename()<CR>",
              opts
            )
          end,
          settings = {
            ["rust-analyzer"] = {
              cargo = {
                allFeatures = true, -- Build with all features enabled
                features = "all", -- Ensure all features are considered during analysis
              },
              check = {
                command = "clippy", -- Use clippy for checking
                features = "all", -- Enable all features for clippy
                extraArgs = {
                  "--all",
                  "--",
                  "-W",
                  "clippy::all",
                  "-W",
                  "clippy::pedantic",
                }, -- Enable more clippy lints
              },
              checkOnSave = true, -- Run checks on save
              diagnostics = {
                enable = true, -- Explicitly enable diagnostics
                disabled = {}, -- Don't disable any diagnostics by default
                enableExperimental = true, -- Enable experimental diagnostics (if available)
              },
              rustc = {
                source = "discover", -- Automatically discover rustc source for better diagnostics
              },
            },
          },
        },
      })
    end,
  },

  {
    "saecki/crates.nvim",
    dependencies = {
      "nvimtools/none-ls.nvim",
    },
    config = function()
      -- rust: integration with crates.nvim for managing dependencies
      require("crates").setup({
        null_ls = {
          enabled = true, -- Enable null-ls integration (optional)
          name = "crates.nvim",
        },
      })
    end,
  },

  {
    "folke/lazydev.nvim",
    dependencies = {
      "folke/lazy.nvim",
    },
    config = function()
      require("lazydev").setup()
    end,
  },

  -- metadata & type support for luvit (uv), an IO library for Lua
  {
    "Bilal2453/luvit-meta",
  },

  -- save and re-load session
  {
    "stevearc/resession.nvim",
    opts = {},
    config = function()
      require("resession").setup({})
    end,
  },

  -- colors: catppuccin
  {
    "catppuccin/nvim",
    name = "catppuccin",
    config = function()
      require("catppuccin").setup({
        flavour = "mocha", -- options: latte, frappe, macchiato, mocha
        -- other configurations if needed
      })
      vim.cmd("colorscheme catppuccin")
    end,
  },

  -- watch for changes in files and reload them
  {
    -- "djoshea/vim-autoread",
    -- dir = "~/dev/vim-autoread",
    "ryanxcharles/vim-autoclose",
  },

  -- Chatvim: public install
  -- {
  --   "chatvim/chatvim.nvim",
  --   build = "npm install",
  --   config = function()
  --     require("chatvim")
  --   end,
  -- },

  -- Chatvim: local install
  {
    dir = "~/dev/chatvim.nvim",
    name = "chatvim.nvim",
    config = function()
      require("chatvim")
    end,
  },
})

-- ## Globals
local opts = { noremap = true, silent = true }

vim.opt.shell = "/opt/homebrew/bin/nu"

-- Show line numbers by default
vim.opt.number = true
vim.opt.relativenumber = true

-- Number of spaces for a tab by default
vim.opt.tabstop = 2 -- Number of spaces for a tab
vim.opt.shiftwidth = 2 -- Number of spaces for auto-indent
vim.opt.expandtab = true -- Use spaces instead of tabs
vim.opt.autoindent = true -- Auto-indent new lines
vim.opt.smartindent = true -- Smart indenting for C-like languages
vim.filetype.add({ extension = { wgsl = "wgsl" } })

-- Two spaces for TypeScript/JavaScript/lua
vim.api.nvim_create_autocmd("FileType", {
  pattern = {
    "javascript",
    "typescript",
    "javascriptreact",
    "typescriptreact",
    "lua",
    "markdown",
    "css",
  },
  callback = function()
    vim.bo.tabstop = 2 -- Number of spaces for a tab
    vim.bo.shiftwidth = 2 -- Number of spaces for auto-indent
    vim.bo.expandtab = true -- Use spaces instead of tabs
    vim.opt_local.autoindent = true -- Auto-indent new lines
    vim.opt_local.smartindent = true -- Smart indenting for C-like languages
  end,
})

-- Special rules for markdown - fix indenting and disable auto-indenting for lists
vim.api.nvim_create_autocmd("FileType", {
  pattern = {
    "markdown",
  },
  callback = function()
    vim.opt_local.indentexpr = ""
    vim.opt_local.formatoptions:remove("o") -- Prevent auto-indenting for lists
  end,
})

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

-- Special rules for markdown - fix indenting and disable auto-indenting for lists
vim.api.nvim_create_autocmd("FileType", {
  pattern = {
    "markdown",
  },
  callback = function()
    vim.opt_local.indentexpr = ""
    vim.opt_local.formatoptions:remove("o") -- Prevent auto-indenting for lists
    -- vim.opt_local.foldenable = false -- Disable folding by default
  end,
})

-- Create a custom command :Fix to run biome lint with --fix and --unsafe options
-- This is useful for sorting tailwind classes
vim.api.nvim_create_user_command("Fix", function()
  local current_file = vim.api.nvim_buf_get_name(0)
  local file_dir = vim.fn.fnamemodify(current_file, ":h")

  vim.cmd("lcd " .. vim.fn.fnameescape(file_dir))
  vim.cmd("!biome lint --fix --unsafe " .. vim.fn.shellescape(current_file))
  vim.cmd("lcd -")
end, {})

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
      vim.cmd("bd " .. buf)
    end
  end
end

-- Create a command to call the function
vim.api.nvim_create_user_command("CloseHiddenBuffers", CloseHiddenBuffers, {})

-- open a terminal in a new vertical split to the right
vim.api.nvim_create_user_command("Term", function()
  vim.cmd("vnew")
  vim.cmd("term")
  vim.cmd("wincmd L")
end, {})

-- open a terminal in a new horizontal split below
vim.api.nvim_create_user_command("TermBelow", function()
  vim.cmd("new")
  vim.cmd("term")
  vim.cmd("wincmd J")
end, {})

vim.api.nvim_create_user_command("LspRenameFile", function(opts)
  local old_file_name = vim.fn.expand("%:p")
  local new_file_name = vim.fn.input("New file name: ", old_file_name, "file")

  if new_file_name ~= old_file_name then
    -- Rename the file in the file system
    vim.fn.rename(old_file_name, new_file_name)

    local clients = vim.lsp.get_clients({ bufnr = 0 })
    local target_client = nil
    for _, client in ipairs(clients) do
      if client.name == "ts_ls" then -- Adjust this if the name is different
        target_client = client
        break
      end
      -- TODO: Also support other LSPs that can handle file renames
    end

    if target_client then
      target_client.request("workspace/executeCommand", {
        command = "_typescript.applyRenameFile",
        arguments = {
          {
            sourceUri = vim.uri_from_fname(old_file_name),
            targetUri = vim.uri_from_fname(new_file_name),
          },
        },
      }, function(err, result, ctx, config)
        if err then
          vim.notify(
            "Error executing command: " .. vim.inspect(err),
            vim.log.levels.ERROR
          )
        else
          vim.notify("File renamed. Remember to :wa !", vim.log.levels.INFO)
        end
      end)
    else
      vim.notify("No ts_ls found among active clients", vim.log.levels.WARN)
    end

    -- Open the new file in the buffer
    vim.cmd("edit " .. new_file_name)
  end
end, {
  nargs = 0,
  desc = "Rename the current file and update imports using the TypeScript LSP",
})

-- Automatically resize windows when the terminal is resized
-- autocmd VimResized * wincmd =
vim.api.nvim_create_autocmd("VimResized", {
  pattern = "*",
  command = "wincmd =",
})

-- Formatting for wgsl and anything else that can use the LSP
local function format_buffer()
  vim.lsp.buf.format()
end

vim.api.nvim_create_user_command("Fmt", format_buffer, {})

-- Function to replace LaTeX math delimiters with Markdown math delimiters
local function replace_math()
  vim.cmd([[
    silent! %s/\\\[\s*/$$/ge
    silent! %s/\s*\\\]/$$/ge
    silent! %s/\\(\s*/$/ge
    silent! %s/\s*\\)/$/ge
  ]])
end

-- Create a user command to trigger the replacements
vim.api.nvim_create_user_command(
  "ReplaceMath",
  replace_math,
  { desc = "Replace LaTeX math delimiters with Markdown delimiters" }
)

-- Create a user command to copy the filename of the current buffer to the system clipboard
vim.api.nvim_create_user_command("CopyFilename", function()
  -- vimscript:
  -- let @+ = expand('%:t')

  -- Get the filename (tail of the path) of the current buffer
  local filename = vim.fn.expand("%:t")
  -- Set the system clipboard register (+) with the filename
  vim.fn.setreg("+", filename)
  -- Optional: Notify the user that the filename has been copied
  vim.notify("Copied filename: " .. filename, vim.log.levels.INFO)
end, { nargs = 0 })

-- ## Keybindings
-- Set space as the leader key. Space is the biggest key and the easiest to
-- hit, so it makes a good leader key.
vim.g.mapleader = " "

-- Lines that wrap will indent to the same level as the start of the line
vim.opt.breakindent = true

-- ctrl+; exits terminal mode
-- vim.api.nvim_set_keymap("t", "<C-;>", [[<C-\><C-n>]], opts)
-- vim.api.nvim_set_keymap("t", "<C-Esc>", [[<C-\><C-n>]], opts)
-- vim.api.nvim_set_keymap("t", "<C-;>", "<C-\\><C-n>", opts)
vim.api.nvim_set_keymap("t", "<Esc>", [[<C-\><C-n>]], opts)

-- Key mappings using leader key
vim.api.nvim_set_keymap("n", "<Leader>w", ":w<CR>", opts)
vim.api.nvim_set_keymap("n", "<Leader>h", "gT", opts)
vim.api.nvim_set_keymap("n", "<Leader>l", "gt", opts)
vim.api.nvim_set_keymap("n", "<Leader>n", ":tabnew<CR>", { silent = true })
vim.api.nvim_set_keymap(
  "n",
  "<Leader>N",
  ":tabnew<CR><Leader>e",
  { silent = true }
)
vim.api.nvim_set_keymap("n", "<Leader>q", ":q<CR>", opts)
vim.api.nvim_set_keymap("n", "<Leader>V", ":vsp<CR>:wincmd l<CR>", opts)
vim.api.nvim_set_keymap("n", "<Leader>v", ":vsp<CR>", opts)

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
-- Make all windows equal size
vim.api.nvim_set_keymap("n", ";=", ":wincmd =<CR>", opts)

-- Scroll down by 25% of the window height
vim.api.nvim_set_keymap(
  "n",
  "<Leader>j",
  ":lua vim.cmd('normal! ' .. math.floor(vim.fn.winheight(0) * 0.25) .. 'jzz')<CR>",
  opts
)
-- Scroll up by 25% of the window height
vim.api.nvim_set_keymap(
  "n",
  "<Leader>k",
  ":lua vim.cmd('normal! ' .. math.floor(vim.fn.winheight(0) * 0.25) .. 'kzz')<CR>",
  opts
)

-- Like * but without jumping to the next instance. i.e., it highlights the
-- current word.
vim.api.nvim_set_keymap(
  "n",
  "<Leader>*",
  [[:lua vim.fn.setreg("/", "\\<" .. vim.fn.expand("<cword>") .. "\\>") vim.opt.hlsearch = true<CR>]],
  opts
)

-- Redraw screen
vim.api.nvim_set_keymap("n", "<Leader>.", "<C-l>", opts)

-- Custom keybindings for Telescope
-- vim.api.nvim_set_keymap('n', '<Leader>ff', ":Telescope find_files<CR>", opts)

-- Key binding to use Telescope to search files, including respecting .gitignore
vim.api.nvim_set_keymap(
  "n",
  "<Leader>e",
  ":lua require('telescope.builtin').find_files({ hidden = true })<CR>",
  opts
)
-- alternate to search git files, e.g. current git repo, instead of cwd/pwd
-- vim.api.nvim_set_keymap(
--   "n",
--   "<Leader>e",
--   ":lua require('telescope.builtin').git_files({ show_untracked = true })<CR>",
--   opts
-- )

-- Telscope search inside files with ripgrep (rg)
vim.api.nvim_set_keymap("n", "<Leader>fg", ":Telescope live_grep<CR>", opts)

-- LSP integration with Telescope for TypeScript and other languages
-- Space + fs: Search document symbols (like variables, functions, etc.).
vim.api.nvim_set_keymap(
  "n",
  "<Leader>fs",
  "<cmd>Telescope lsp_document_symbols<CR>",
  opts
)
-- Space + fr: Find all references to a symbol.
vim.api.nvim_set_keymap(
  "n",
  "<Leader>fr",
  "<cmd>Telescope lsp_references<CR>",
  opts
)
-- Space + fd: Search through diagnostics (errors, warnings).
vim.api.nvim_set_keymap(
  "n",
  "<Leader>fd",
  "<cmd>Telescope diagnostics<CR>",
  opts
)
-- Show all diagnostics on the current line in a floating window
vim.api.nvim_set_keymap(
  "n",
  "<Leader>ds",
  "<cmd>lua vim.diagnostic.open_float(nil, { focusable = false })<CR>",
  opts
)
-- Go to the next diagnostic (error, warning, etc.)
vim.api.nvim_set_keymap(
  "n",
  "<Leader>dn",
  ":lua vim.diagnostic.goto_next()<CR>",
  opts
)
-- Go to the previous diagnostic (error, warning, etc.)
vim.api.nvim_set_keymap(
  "n",
  "<Leader>dN",
  ":lua vim.diagnostic.goto_prev()<CR>",
  opts
)

-- Set custom keybindings for cycling through Copilot suggestions
vim.api.nvim_set_keymap("i", "<C-n>", "copilot#Next()", opts)
vim.api.nvim_set_keymap("i", "<C-p>", "copilot#Previous()", opts)

-- Keybinding to toggle Neo-tree
vim.api.nvim_set_keymap("n", "<Leader>tt", ":Neotree toggle<CR>", opts)
-- Neo-tree files
vim.api.nvim_set_keymap(
  "n",
  "<Leader>tf",
  ":Neotree filesystem position=left<CR>",
  opts
)
-- Neo-tree reveal current file
vim.api.nvim_set_keymap(
  "n",
  "<Leader>tr",
  ":Neotree reveal position=left<CR>",
  opts
)
-- Neo-tree buffers
vim.api.nvim_set_keymap(
  "n",
  "<Leader>tb",
  ":Neotree buffers position=left<CR>",
  opts
)
-- Neo-tree git status
vim.api.nvim_set_keymap("n", "<Leader>tg", ":Neotree git_status<CR>", opts)
-- Keybinding to open Neo-tree buffer list in a floating window (on-demand)
vim.api.nvim_set_keymap(
  "n",
  "<Leader>tB",
  ":Neotree buffers position=float<CR>",
  opts
)
-- Keybinding to open Neo-tree file list in a floating window (on-demand)
vim.api.nvim_set_keymap(
  "n",
  "<Leader>tF",
  ":Neotree filesystem position=float<CR>",
  opts
)
-- Keybinding to open Neo-tree reveal current file in a floating window (on-demand)
vim.api.nvim_set_keymap(
  "n",
  "<Leader>tR",
  ":Neotree reveal position=float<CR>",
  opts
)
-- Keybinding to open Neo-tree buffer list in current window (on-demand)
vim.api.nvim_set_keymap(
  "n",
  "<Leader>tcb",
  ":Neotree buffers position=current<CR>",
  opts
)
-- Keybinding to open Neo-tree file list in current window (on-demand)
vim.api.nvim_set_keymap(
  "n",
  "<Leader>tcf",
  ":Neotree filesystem position=current<CR>",
  opts
)
-- Keybinding to open Neo-tree reveal current file in current window (on-demand)
vim.api.nvim_set_keymap(
  "n",
  "<Leader>tcr",
  ":Neotree reveal position=current<CR>",
  opts
)

-- Keybindings for resession
vim.api.nvim_set_keymap(
  "n",
  "<Leader>ss",
  ":lua require('resession').save()<CR>",
  opts
)
vim.api.nvim_set_keymap(
  "n",
  "<Leader>sl",
  ":lua require('resession').load()<CR>",
  opts
)
vim.api.nvim_set_keymap(
  "n",
  "<Leader>sd",
  ":lua require('resession').delete()<CR>",
  opts
)
vim.api.nvim_set_keymap(
  "n",
  "<Leader>sc",
  ":lua require('resession').autosave_toggle()<CR>",
  opts
)

-- Go to definition
vim.api.nvim_set_keymap(
  "n",
  "gd",
  "<cmd>lua vim.lsp.buf.definition()<CR>",
  opts
)

-- LSP-related keybindings

-- Hover documentation
vim.api.nvim_set_keymap("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)

-- Find references
vim.api.nvim_set_keymap(
  "n",
  "gr",
  "<cmd>lua vim.lsp.buf.references()<CR>",
  opts
)

-- Go to implementation
vim.api.nvim_set_keymap(
  "n",
  "gi",
  "<cmd>lua vim.lsp.buf.implementation()<CR>",
  opts
)

-- Rename symbol
vim.api.nvim_set_keymap(
  "n",
  "<Leader>rn",
  "<cmd>lua vim.lsp.buf.rename()<CR>",
  opts
)

-- Code actions
vim.api.nvim_set_keymap(
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

-- zt: scroll so current line is 10 lines from top
vim.keymap.set("n", "zt", "zt10<C-y>", opts)
-- zb: scroll so current line is 10 lines from bottom
vim.keymap.set("n", "zb", "zb10<C-e>", opts)

-- Chatvim (chatvim.nvim) keybindings
-- let opts = { noremap = true, silent = true }
vim.api.nvim_set_keymap("n", "<Leader>cvc", ":ChatvimComplete<CR>", opts)
vim.api.nvim_set_keymap("n", "<Leader>cvs", ":ChatvimStop<CR>", opts)
vim.api.nvim_set_keymap("n", "<Leader>cvnn", ":ChatvimNew<CR>", opts)
vim.api.nvim_set_keymap("n", "<Leader>cvnl", ":ChatvimNew left<CR>", opts)
vim.api.nvim_set_keymap("n", "<Leader>cvnr", ":ChatvimNew right<CR>", opts)
vim.api.nvim_set_keymap("n", "<Leader>cvnb", ":ChatvimNew bottom<CR>", opts)
vim.api.nvim_set_keymap("n", "<Leader>cvnt", ":ChatvimNew top<CR>", opts)

-- ## Colors

-- Enable 24-bit RGB color in the terminal
vim.opt.termguicolors = true

-- TODO: test todo highlighting
-- Define a highlight group for TODO comments
vim.api.nvim_command(
  "highlight TodoComment guifg=#FA8603 guibg=#1e1e2e gui=bold"
) -- Orange color with bold
-- Automatically highlight TODO comments when entering a buffer
vim.api.nvim_create_autocmd({ "BufEnter", "BufReadPost" }, {
  group = vim.api.nvim_create_augroup("TodoHighlight", { clear = true }),
  pattern = "*",
  callback = function()
    vim.fn.matchadd("TodoComment", "TODO:")
  end,
})

-- Set background colors for active and inactive windows
-- Define the colors for active and inactive windows
-- vim.api.nvim_set_hl(0, "ActiveWindow", { bg = "#0f0f16" }) -- Active window background color
-- vim.api.nvim_set_hl(0, "InactiveWindow", { bg = "#14161b" }) -- Inactive window background color
-- vim.api.nvim_set_hl(0, "InactiveWindow", { bg = "NONE" }) -- Inactive window background color

-- Set Neovim background to transparent
-- vim.api.nvim_set_hl(0, "Normal", { bg = "#04060b" })
-- vim.api.nvim_set_hl(0, "NormalNC", { bg = "#04060b" })
vim.api.nvim_set_hl(0, "Normal", { bg = "NONE" })
vim.api.nvim_set_hl(0, "NormalNC", { bg = "NONE" })

-- Autocommand for entering a window (active)
vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
  callback = function()
    vim.wo.winhighlight = "Normal:ActiveWindow" -- Set active window background
  end,
})

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
  -- { fg = "#ffffff", bg = "#14161b", bold = false }
  { fg = "#ffffff", bg = "NONE", bold = false }
) -- Non-selected tabs

vim.opt.fillchars = {
  horiz = "━",
  horizup = "┻",
  horizdown = "┳",
  vert = "┃",
  vertleft = "┫",
  vertright = "┣",
  verthoriz = "╋",
}

-- Make active window separator more visible
vim.api.nvim_set_hl(0, "WinSeparatorNC", { fg = "#1E1E2E" }) -- inactive window separator
vim.api.nvim_set_hl(0, "WinSeparator", { fg = "#a6e3a1" }) -- active window separator
vim.opt.winhl = "WinSeparator:WinSeparator"
vim.api.nvim_set_hl(0, "NormalNC", { bg = "#1E1E2E" }) -- active window background
vim.api.nvim_set_hl(0, "Normal", { bg = "#161626" }) -- inactive window background

-- Enable window borders globally
vim.opt.number = true -- This helps with left border visibility
vim.opt.relativenumber = true -- Optional
vim.opt.signcolumn = "yes" -- This helps ensure left border space
vim.opt.foldcolumn = "1" -- This can help with left border too

-- Create autocmd for window focus
vim.api.nvim_create_autocmd(
  { "WinEnter", "BufEnter", "WinLeave", "BufLeave" },
  {
    callback = function()
      local wins = vim.api.nvim_list_wins()
      for _, w in ipairs(wins) do
        if w == vim.api.nvim_get_current_win() then
          -- Current window gets highlighted border and background
          vim.wo[w].winhighlight = "WinSeparator:WinSeparator,Normal:Normal"
        else
          -- Other windows get dim border and background
          vim.wo[w].winhighlight = "WinSeparator:WinSeparatorNC,Normal:NormalNC"
        end
      end
    end,
  }
)

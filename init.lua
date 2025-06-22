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
-- - ruff (for Python diagnostics)

-- TODO:
-- [ ] replace formatter with null-ls
-- [ ] Add Gitsigns (lewis6991/gitsigns.nvim)
-- [ ] Add markdown-preview.nvim (iamcco/markdown-preview.nvim)
-- [ ] replace rainbow-delimiters with nvim-ts-rainbow (p00f/nvim-ts-rainbow)

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

local original_path = package.path
package.path = package.path .. ";" .. vim.fn.stdpath("config") .. "/?.lua"

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
        settings = {
          python = {
            pythonPath = vim.fn.getcwd() .. "/.venv/bin/python", -- Use cwd as artintellica
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

  -- GitHub Copilot
  {
    "github/copilot.vim", -- GitHub Copilot
    config = function()
      -- require("plugin-copilot")
    end,
  },

  -- Copilot completion source for nvim-cmp
  {
    "zbirenbaum/copilot-cmp", -- Copilot completion source for cmp
    dependencies = { "github/copilot.vim" }, -- Ensure it loads after copilot.vim
    config = function()
      require("copilot_cmp").setup()
    end,
  },

  -- Copilot Chat
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      { "github/copilot.vim" }, -- or zbirenbaum/copilot.lua
      { "nvim-lua/plenary.nvim", branch = "master" }, -- for curl, log and async functions
    },
    build = "make tiktoken", -- Only on MacOS or Linux
    opts = {
      -- See Configuration section for options
    },
    -- See Commands section for default commands if you want to lazy load on them
  },

  -- nushell
  {
    "LhKipp/nvim-nu",
    config = function()
      require("nu").setup()
    end,
  },

  -- Treesitter for syntax highlighting
  -- {
  --   "nvim-treesitter/nvim-treesitter",
  --   dependencies = {
  --     "LhKipp/nvim-nu",
  --   },
  --   run = ":TSUpdate",
  -- },

  -- Treesitter for syntax highlighting and text-objects for selecting markdown code blocks
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    dependencies = { "nvim-treesitter/nvim-treesitter", "LhKipp/nvim-nu" },
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
    end,
  },

  -- Code formatting
  {
    "mhartington/formatter.nvim",
    config = function()
      local uv = vim.loop -- Use Neovim's built-in libuv wrapper for filesystem operations

      -- Function to recursively search for a file in the current directory or any parent directory
      local function find_file_in_cwd_parents(filename)
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
                find_file_in_cwd_parents("deno.json")
                or find_file_in_cwd_parents("deno.jsonc")
              then
                return {
                  exe = "deno",
                  args = { "fmt", "-" }, -- Format via stdin
                  stdin = true,
                }
              else
                -- Use Biome for non-Deno TypeScript projects
                local config_path = find_file_in_file_parents(
                  "biome.json",
                  vim.api.nvim_buf_get_name(0)
                )
                return {
                  exe = "biome",
                  args = {
                    "format",
                    "--config-path",
                    config_path,
                    "--stdin-file-path",
                    string.format('"%s"', vim.api.nvim_buf_get_name(0)),
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
                find_file_in_cwd_parents("deno.json")
                or find_file_in_cwd_parents("deno.jsonc")
              then
                return {
                  exe = "deno",
                  args = { "fmt", "-" }, -- Format via stdin
                  stdin = true,
                }
              else
                local config_path = find_file_in_file_parents(
                  "biome.json",
                  vim.api.nvim_buf_get_name(0)
                )
                return {
                  exe = "biome",
                  args = {
                    "format",
                    "--config-path",
                    config_path,
                    "--stdin-file-path",
                    string.format('"%s"', vim.api.nvim_buf_get_name(0)),
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
                find_file_in_cwd_parents("deno.json")
                or find_file_in_cwd_parents("deno.jsonc")
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
                local config_path = find_file_in_file_parents(
                  "biome.json",
                  vim.api.nvim_buf_get_name(0)
                )
                return {
                  exe = "biome",
                  args = {
                    "format",
                    "--config-path",
                    config_path,
                    "--stdin-file-path",
                    string.format('"%s"', vim.api.nvim_buf_get_name(0)),
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
                find_file_in_cwd_parents("deno.json")
                or find_file_in_cwd_parents("deno.jsonc")
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
                local config_path = find_file_in_file_parents(
                  "biome.json",
                  vim.api.nvim_buf_get_name(0)
                )
                return {
                  exe = "biome",
                  args = {
                    "format",
                    "--config-path",
                    config_path,
                    "--stdin-file-path",
                    string.format('"%s"', vim.api.nvim_buf_get_name(0)),
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
                find_file_in_cwd_parents("deno.json")
                or find_file_in_cwd_parents("deno.jsonc")
              then
                return {
                  exe = "deno",
                  args = { "fmt", "-" }, -- Format via stdin
                  stdin = true,
                }
              else
                local config_path = find_file_in_file_parents(
                  "biome.json",
                  vim.api.nvim_buf_get_name(0)
                )
                return {
                  exe = "biome",
                  args = {
                    "format",
                    "--config-path",
                    config_path,
                    "--stdin-file-path",
                    string.format('"%s"', vim.api.nvim_buf_get_name(0)),
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
                find_file_in_cwd_parents("deno.json")
                or find_file_in_cwd_parents("deno.jsonc")
              then
                return {
                  exe = "deno",
                  args = { "fmt", "-" }, -- Format via stdin
                  stdin = true,
                }
              else
                local config_path = find_file_in_file_parents(
                  "biome.json",
                  vim.api.nvim_buf_get_name(0)
                )
                return {
                  exe = "biome",
                  args = {
                    "format",
                    "--config-path",
                    config_path,
                    "--stdin-file-path",
                    string.format('"%s"', vim.api.nvim_buf_get_name(0)),
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
                args = {
                  "--indent-type",
                  "Spaces",
                  "--indent-width",
                  "2",
                  "--search-parent-directories",
                  "-",
                },
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
          wgsl = {
            function()
              return {
                exe = "wgsl_analyzer",
                args = { "format" },
                stdin = true,
              }
            end,
          },
          python = {
            function()
              return {
                exe = "black",
                args = { "-" },
                stdin = true,
              }
            end,
          },
        },
      })
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
          "nu",
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
      require("plugin-lualine")
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
      require("plugin-neo-tree")
    end,
  },

  -- Codewindow setup (minimap)
  {
    "gorbit99/codewindow.nvim",
    config = function()
      require("plugin-codewindow")
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
      require("plugin-rust-tools")
    end,
  },

  {
    "saecki/crates.nvim",
    dependencies = {
      "nvimtools/none-ls.nvim",
    },
    config = function()
      require("plugin-crates")
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

  -- ChatVim: public install
  -- {
  --   "chatvim/chatvim.nvim",
  --   build = "npm install",
  --   config = function()
  --     require("chatvim")
  --   end,
  -- },

  -- ChatVim: local install
  {
    dir = "~/dev/chatvim.nvim",
    name = "chatvim.nvim",
    config = function()
      require("chatvim")
    end,
  },
})

-- local config_path = vim.fn.stdpath("config") .. "/lua/"
require("globals")
require("keybindings")
require("colors")

package.path = original_path

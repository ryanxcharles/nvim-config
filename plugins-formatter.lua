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

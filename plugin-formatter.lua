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
    wgsl = {
      function()
        return {
          exe = "wgsl_analyzer",
          args = { "format" },
          stdin = true,
        }
      end,
    },
  },
})

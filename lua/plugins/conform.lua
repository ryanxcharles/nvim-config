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

return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      markdown = { "dprint" },
      toml = { "dprint" },
      typescript = { "prettier" },
      typescriptreact = { "prettier" },
      javascript = { "prettier" },
      javascriptreact = { "prettier" },
      json = { "prettier" },
      jsonc = { "prettier" },
      lua = { "stylua" },
      rust = { "rustfmt" },
      python = { "black" },
      nu = { "topiary" },
      wgsl = { "wgsl_analyzer" },
      tex = { "latexindent" },
    },
    formatters = {
      latexindent = {
        command = "latexindent",
        args = { "-" }, -- reads from stdin / writes to stdout
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
  },
  -- config = function()
  --   -- Function to search for a file (filename) in the directory of another file (full_path)
  --   -- and recursively in its parent directories.
  --   local function find_file_in_file_parents(filename, full_path)
  --     -- Get the directory of the file passed in as full_path
  --     local dir = vim.fn.fnamemodify(full_path, ":h") -- ":h" extracts the directory from full_path
  --     --print("Starting search in directory: " .. dir)
  --
  --     while dir do
  --       local filepath = dir .. "/" .. filename
  --       --print("Checking for file at: " .. filepath) -- Debug print
  --
  --       local stat = vim.loop.fs_stat(filepath)
  --       if stat then
  --         print("File found: " .. filepath) -- Debug print when file is found
  --         return filepath -- Return the absolute file path if found
  --       end
  --
  --       -- Move to the parent directory
  --       local parent = dir:match("(.*/)[^/]+/?$")
  --       if not parent or parent == dir then
  --         --print("Reached root directory, stopping search.") -- Debug print
  --         break -- Reached the root directory
  --       end
  --
  --       --print("Moving to parent directory: " .. parent) -- Debug print for parent
  --       dir = parent
  --     end
  --
  --     print("File not found.") -- Debug print when file is not found
  --     return nil -- File not found
  --   end
  --   require("conform").setup({
  --     formatters_by_ft = {
  --       markdown = { "dprint" },
  --       toml = { "dprint" },
  --       typescript = { "prettier" },
  --       typescriptreact = { "prettier" },
  --       javascript = { "prettier" },
  --       javascriptreact = { "prettier" },
  --       json = { "prettier" },
  --       jsonc = { "prettier" },
  --       lua = { "stylua" },
  --       rust = { "rustfmt" },
  --       python = { "black" },
  --       nu = { "topiary" },
  --       wgsl = { "wgsl_analyzer" },
  --       tex = { "latexindent" },
  --     },
  --     -- format_on_save = false,
  --     -- format_on_save = {
  --     --   timeout_ms = 500,
  --     --   lsp_fallback = true,
  --     -- },
  --     formatters = {
  --       latexindent = {
  --         command = "latexindent",
  --         args = { "-" }, -- reads from stdin / writes to stdout
  --         stdin = true,
  --       },
  --       dprint = {
  --         command = "dprint",
  --         args = function(self, ctx)
  --           return { "fmt", "--stdin", ctx.filename }
  --         end,
  --         stdin = true,
  --       },
  --       stylua = {
  --         command = "stylua",
  --         args = {
  --           "--indent-type",
  --           "Spaces",
  --           "--indent-width",
  --           "2",
  --           "--search-parent-directories",
  --           "-",
  --         },
  --         stdin = true,
  --       },
  --       rustfmt = {
  --         command = "rustfmt",
  --         args = { "--emit", "stdout" },
  --         stdin = true,
  --       },
  --       black = {
  --         command = "black",
  --         args = { "-" },
  --         stdin = true,
  --       },
  --       topiary = {
  --         command = "topiary",
  --         args = { "format", "--language", "nu" },
  --         stdin = true,
  --       },
  --       wgsl_analyzer = {
  --         command = "wgsl_analyzer",
  --         args = { "format" },
  --         stdin = true,
  --       },
  --     },
  --   })
  --
  --   vim.api.nvim_create_user_command("Format", function(args)
  --     local range = nil
  --     if args.count ~= -1 then
  --       local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
  --       range = {
  --         start = { args.line1, 0 },
  --         ["end"] = { args.line2, end_line:len() },
  --       }
  --     end
  --     require("conform").format({
  --       async = true,
  --       lsp_format = "fallback",
  --       range = range,
  --     })
  --   end, { range = true })
  -- end,
}

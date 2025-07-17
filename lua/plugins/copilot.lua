return {
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
      nu = false, -- Disable for Nushell files
    }
  end,
}

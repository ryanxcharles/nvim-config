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

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

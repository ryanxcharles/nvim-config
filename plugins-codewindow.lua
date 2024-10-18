-- Codewindow setup (minimap)
local codewindow = require("codewindow")
codewindow.setup({
  -- <Leader>mo - open the minimap
  -- <Leader>mc - close the minimap
  -- <Leader>mf - focus/unfocus the minimap
  -- <Leader>mm - toggle the minimap
  minimap_width = 10,
  auto_enable = false,
  -- no window border
  -- border options: 'none', 'single', 'double'
  window_border = "single",
})
codewindow.apply_default_keybinds()

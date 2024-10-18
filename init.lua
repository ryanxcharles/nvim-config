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
-- - git (for git integration)
-- - tailwindcss-language-server (for Tailwind CSS completions and colors)
-- - typescript-language-server (for TypeScript completions and diagnostics)
-- - rust/cargo (for Rust tools)
-- - lua-language-server (for Lua completions and diagnostics)

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

require("lazy").setup(require("plugins"))
require("globals")
require("keybindings")
require("colors")


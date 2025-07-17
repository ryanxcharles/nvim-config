-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Globals
local opts = { noremap = true, silent = true }
vim.opt.shell = "/opt/homebrew/bin/nu"

-- Window navigation
vim.api.nvim_set_keymap("n", ";h", ":wincmd h<CR>", opts)
vim.api.nvim_set_keymap("n", ";l", ":wincmd l<CR>", opts)
vim.api.nvim_set_keymap("n", ";k", ":wincmd k<CR>", opts)
vim.api.nvim_set_keymap("n", ";j", ":wincmd j<CR>", opts)

-- Key mappings using leader key
-- vim.api.nvim_set_keymap("n", "<Leader>w", ":w<CR>", opts)
-- vim.api.nvim_set_keymap("n", "<Leader>h", "gT", opts)
-- vim.api.nvim_set_keymap("n", "<Leader>l", "gt", opts)
-- vim.api.nvim_set_keymap("n", "<Leader>n", ":tabnew<CR>", { silent = true })
-- vim.api.nvim_set_keymap("n", "<Leader>N", ":tabnew<CR><Leader>e", { silent = true })
-- vim.api.nvim_set_keymap("n", "<Leader>q", ":q<CR>", opts)
vim.api.nvim_set_keymap("n", "<Leader>V", ":vsp<CR>:wincmd l<CR>", opts)
vim.api.nvim_set_keymap("n", "<Leader>v", ":vsp<CR>", opts)

-- Keybindings for resession
vim.api.nvim_set_keymap("n", "<Leader>sr", ":lua require('resession').save()<CR>", opts)
vim.api.nvim_set_keymap("n", "<Leader>sl", ":lua require('resession').load()<CR>", opts)
vim.api.nvim_set_keymap("n", "<Leader>sd", ":lua require('resession').delete()<CR>", opts)

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

vim.api.nvim_set_keymap("n", "<Leader>chb", ":CloseHiddenBuffers<CR>", {})

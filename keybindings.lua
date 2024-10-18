local opts = { noremap = true, silent = true }

-- Set space as the leader key. Space is the biggest key and the easiest to
-- hit, so it makes a good leader key.
vim.g.mapleader = " "

-- Lines that wrap will indent to the same level as the start of the line
vim.opt.breakindent = true

-- Disable folding by default
-- vim.opt.foldenable = false

-- Show cursor line
-- vim.opt.cursorline = true
-- vim.opt.cursorcolumn = true

-- ctrl+escape exits terminal mode
vim.api.nvim_set_keymap('t', '<C-;>', [[<C-\><C-n>]], opts)

-- Key mappings using leader key
vim.api.nvim_set_keymap("n", "<Leader>w", ":w<CR>", opts)
vim.api.nvim_set_keymap("n", "<Leader>h", "gT", opts)
vim.api.nvim_set_keymap("n", "<Leader>l", "gt", opts)
vim.api.nvim_set_keymap("n", "<Leader>n", ":tabnew<CR>", { silent = true })
vim.api.nvim_set_keymap(
  "n",
  "<Leader>N",
  ":tabnew<CR><Leader>e",
  { silent = true }
)
vim.api.nvim_set_keymap("n", "<Leader>q", ":q<CR>", opts)
vim.api.nvim_set_keymap("n", "<Leader>v", ":vsp<CR>:wincmd l<CR>", opts)

-- Window navigation
vim.api.nvim_set_keymap("n", ";h", ":wincmd h<CR>", opts)
vim.api.nvim_set_keymap("n", ";l", ":wincmd l<CR>", opts)
vim.api.nvim_set_keymap("n", ";k", ":wincmd k<CR>", opts)
vim.api.nvim_set_keymap("n", ";j", ":wincmd j<CR>", opts)
-- Move to window 1-9
vim.api.nvim_set_keymap("n", ";1", ":1wincmd w<CR>", opts)
vim.api.nvim_set_keymap("n", ";2", ":2wincmd w<CR>", opts)
vim.api.nvim_set_keymap("n", ";3", ":3wincmd w<CR>", opts)
vim.api.nvim_set_keymap("n", ";4", ":4wincmd w<CR>", opts)
vim.api.nvim_set_keymap("n", ";5", ":5wincmd w<CR>", opts)
vim.api.nvim_set_keymap("n", ";6", ":6wincmd w<CR>", opts)
vim.api.nvim_set_keymap("n", ";7", ":7wincmd w<CR>", opts)
vim.api.nvim_set_keymap("n", ";8", ":8wincmd w<CR>", opts)
vim.api.nvim_set_keymap("n", ";9", ":9wincmd w<CR>", opts)
-- Make all windows equal size
vim.api.nvim_set_keymap("n", ";=", ":wincmd =<CR>", opts)

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

-- Like * but without jumping to the next instance. i.e., it highlights the
-- current word.
vim.api.nvim_set_keymap(
  "n",
  "<Leader>*",
  [[:lua vim.fn.setreg("/", "\\<" .. vim.fn.expand("<cword>") .. "\\>") vim.opt.hlsearch = true<CR>]],
  opts
)

-- Redraw screen
vim.api.nvim_set_keymap("n", "<Leader>.", "<C-l>", opts)

-- Custom keybindings for Telescope
-- vim.api.nvim_set_keymap('n', '<Leader>ff', ":Telescope find_files<CR>", opts)

-- Key binding to use Telescope to search files, including respecting .gitignore
vim.api.nvim_set_keymap(
  "n",
  "<Leader>e",
  ":lua require('telescope.builtin').git_files({ show_untracked = true })<CR>",
  opts
)

-- Telscope search inside files with ripgrep (rg)
vim.api.nvim_set_keymap("n", "<Leader>fg", ":Telescope live_grep<CR>", opts)

-- LSP integration with Telescope for TypeScript and other languages
-- Space + fs: Search document symbols (like variables, functions, etc.).
vim.api.nvim_set_keymap(
  "n",
  "<Leader>fs",
  "<cmd>Telescope lsp_document_symbols<CR>",
  opts
)
-- Space + fr: Find all references to a symbol.
vim.api.nvim_set_keymap(
  "n",
  "<Leader>fr",
  "<cmd>Telescope lsp_references<CR>",
  opts
)
-- Space + fd: Search through diagnostics (errors, warnings).
vim.api.nvim_set_keymap(
  "n",
  "<Leader>fd",
  "<cmd>Telescope diagnostics<CR>",
  opts
)
-- Show all diagnostics on the current line in a floating window
vim.api.nvim_set_keymap(
  "n",
  "<Leader>ds",
  "<cmd>lua vim.diagnostic.open_float(nil, { focusable = false })<CR>",
  opts
)
-- Go to the next diagnostic (error, warning, etc.)
vim.api.nvim_set_keymap(
  "n",
  "<Leader>dn",
  ":lua vim.diagnostic.goto_next()<CR>",
  opts
)
-- Go to the previous diagnostic (error, warning, etc.)
vim.api.nvim_set_keymap(
  "n",
  "<Leader>dp",
  ":lua vim.diagnostic.goto_prev()<CR>",
  opts
)

-- Key binding to reload init.lua file
vim.api.nvim_set_keymap(
  "n",
  "<Leader>rl",
  ":luafile ~/.config/nvim/init.lua<CR>",
  opts
)

-- rust: Rust-specific keybindings
vim.api.nvim_set_keymap("n", "<Leader>rr", ":!cargo run<CR>", opts)
vim.api.nvim_set_keymap("n", "<Leader>rt", ":!cargo test<CR>", opts)
vim.api.nvim_set_keymap("n", "<Leader>rb", ":!cargo build<CR>", opts)

-- Optional keybinding to update dependencies with `crates.nvim`
vim.api.nvim_set_keymap(
  "n",
  "<Leader>cu",
  ":lua require('crates').update_crate()<CR>",
  opts
)

-- Set custom keybindings for cycling through Copilot suggestions
vim.api.nvim_set_keymap(
  "i",
  "<C-n>",
  "copilot#Next()",
  { silent = true, expr = true }
)
vim.api.nvim_set_keymap(
  "i",
  "<C-p>",
  "copilot#Previous()",
  { silent = true, expr = true }
)

-- Keybinding to toggle Neo-tree
vim.api.nvim_set_keymap("n", "<Leader>tt", ":Neotree toggle<CR>", opts)
-- Neo-tree files
vim.api.nvim_set_keymap("n", "<Leader>tf", ":Neotree filesystem<CR>", opts)
-- Neo-tree buffers
vim.api.nvim_set_keymap("n", "<Leader>tb", ":Neotree buffers<CR>", opts)
-- Neo-tree git status
vim.api.nvim_set_keymap("n", "<Leader>tg", ":Neotree git_status<CR>", opts)
-- Keybinding to open Neo-tree buffer list in a floating window (on-demand)
vim.api.nvim_set_keymap(
  "n",
  "<Leader>tB",
  ":Neotree buffers position=float<CR>",
  opts
)
-- Keybinding to open Neo-tree file list in a floating window (on-demand)
vim.api.nvim_set_keymap(
  "n",
  "<Leader>tF",
  ":Neotree filesystem position=float<CR>",
  opts
)


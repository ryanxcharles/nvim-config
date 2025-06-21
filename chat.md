in neovim, i often love to center the current line by pressing `zz`. is there a way to make it so that the current line is top or bottom rather than center?

# === ASSISTANT ===

Absolutely! In Neovim (and Vim), the `zz` command **centers** the current line in the window. There are also built-in commands to move the current line to the **top** or **bottom** of the window:

- `zt` &nbsp;→&nbsp; Move current line to **top** of window
- `zz` &nbsp;→&nbsp; Move current line to **center** of window
- `zb` &nbsp;→&nbsp; Move current line to **bottom** of window

**Example:**
- Place cursor on a line, hit `zt` → line moves to the top.
- Place cursor on a line, hit `zb` → line moves to the bottom.

**No plugins or remaps required!** These are standard commands. If you want, you can remap them to a different key sequence, but `zt` and `zb` are available out-of-the-box.

# === USER ===

great, now, it doesn't seem the `zT` or `zB` commands do anything. i'd like to make `zT` the same as `zt`, except offset by 10 lines, so that i can see what's just above that line. similarly, `zB` would be the same as `zb`, but offset by 10 lines so that i can see what's just below that line. how can i do this?

# === ASSISTANT ===

Great idea! Out of the box, `zT` and `zB` are not standard commands in Vim/Neovim—they don't do anything by default. However, you can **remap** them in your `init.vim` (Vimscript) or `init.lua` (Lua, for Neovim) config to achieve this behavior.

### What you want:
- `zT`: current line is 10 lines from the top of the window
- `zB`: current line is 10 lines from the bottom of the window

---

## Vimscript (`init.vim`)

```vim
" zT: scroll so current line is 10 lines from top
nnoremap zT 10<C-y>zt

" zB: scroll so current line is 10 lines from bottom
nnoremap zB 10<C-e>zb
```

**How it works:**
- `<C-y>` scrolls up one line (without moving the cursor).
- `<C-e>` scrolls down one line (without moving the cursor).
- `zt`/`zb` aligns the line with top/bottom.
- So: you scroll 10 extra lines, then position the line.

---

## Lua (`init.lua` for Neovim)

```lua
-- zT: scroll so current line is 10 lines from top
vim.keymap.set('n', 'zT', '10<C-y>zt', { noremap = true, silent = true })

-- zB: scroll so current line is 10 lines from bottom
vim.keymap.set('n', 'zB', '10<C-e>zb', { noremap = true, silent = true })
```

---

## Usage

- Place the mappings above in your config.
- Restart Neovim.
- Press `zT` or `zB` in normal mode.

**Adjust "10" to any value** for a bigger or smaller offset!

---

### 🔬 **Optional:** To see the effect, open a long file and move your cursor around, then use the new `zT` and `zB` commands.

Let me know if you'd like a *smarter* function (e.g. one that doesn't scroll past the window edges)!

# === USER ===

that's not quite what i want. that moves the cursor and then scrolls. i want to scroll and make sure the cursor is on the same line as before. how do i do that?

# === ASSISTANT ===

Great catch!  
You're right: the mappings I gave (`10<C-y>zt` and `10<C-e>zb`) move the window, and then place the cursor line at the top or bottom, but then *move the window more*, so the cursor is *not* in the same spot relative to the file.

**What you want:**  
- Move the window so the current line is `10` lines below the top (for `zT`), while keeping the cursor on the same *buffer* line.
- Move the window so the current line is `10` lines above the bottom (for `zB`), while keeping the cursor on the same buffer line.

This is **not a built-in command**, but you can simulate it using Vim's `scrolloff` and the `:normal!` command.

---

## Solution 1: Pure Mapping with line movement and window scroll

We'll make a mapping that:
- Remembers your cursor line number (row),
- Runs a window scroll so line is at top,
- Scrolls window down/up by 10 lines (leaving cursor untouched).

**Vimscript version:**
```vim
" zT: place cursor's line 10 lines beneath the top of window
nnoremap zT :call cursor(line('.'), col('.'))<CR>zt10<C-e>

" zB: place cursor's line 10 lines above the bottom of window
nnoremap zB :call cursor(line('.'), col('.'))<CR>zb10<C-y>
```
But you will notice that this still risks moving the cursor if the window can't scroll enough. Let's do it more precisely with a function:

---

## Solution 2: Custom function (works in Neovim Vimscript/Lua)

### Vimscript function

```vim
function! CenterLineOffsetTop(offset)
  let lnum = line('.')
  execute "normal! zt"
  execute "normal! " . a:offset . "\<C-e>"
endfunction

function! CenterLineOffsetBottom(offset)
  let lnum = line('.')
  execute "normal! zb"
  execute "normal! " . a:offset . "\<C-y>"
endfunction

nnoremap zT :call CenterLineOffsetTop(10)<CR>
nnoremap zB :call CenterLineOffsetBottom(10)<CR>
```

### Lua function (Neovim)

```lua
local function zT_offset(offset)
  vim.cmd("normal! zt")
  vim.cmd("normal! " .. offset .. "<C-e>")
end

local function zB_offset(offset)
  vim.cmd("normal! zb")
  vim.cmd("normal! " .. offset .. "<C-y>")
end

vim.keymap.set('n', 'zT', function() zT_offset(10) end, { noremap = true, silent = true })
vim.keymap.set('n', 'zB', function() zB_offset(10) end, { noremap = true, silent = true })
```

---

**These solutions keep your cursor on the exact same line**, but shifts the window so it is offset from the top (zT) or bottom (zB). If the window can't scroll all the way (e.g., file start/end), Vim will do its best.

---

## Summary (TL;DR)

- `zt10<C-e>`: puts cursor's line at top, then window scrolls down 10 lines.
- `zb10<C-y>`: puts cursor's line at bottom, then window scrolls up 10 lines.
- The function/mapping **does not move your cursor in the buffer**, only how the window displays around it.

---

### **Try this:**
```vim
nnoremap zT zt10<C-e>
nnoremap zB zb10<C-y>
```
or in Lua:
```lua
vim.keymap.set('n', 'zT', 'zt10<C-e>', { noremap = true, silent = true })
vim.keymap.set('n', 'zB', 'zb10<C-y>', { noremap = true, silent = true })
```

This will keep your cursor on the original line as the window scrolls!

---

Let me know if you want more advanced behavior (e.g., dynamically center based on window size, etc.).

# === USER ===

i have a problem with my nvim config. with large markdown files, there is a problem with completions. it seems to complete anything i type with whatever is in the markdown file. this is a problem for big markdown files because it starts to get slow. i NEVER want ANY completions from the text of the current file. how can i disable these completions correctly? am i correct that this type of completion are called "buffer" completions? here is my config:

```lua
  {
    "hrsh7th/nvim-cmp",
    -- dependencies = {
    --   "roobert/tailwindcss-colorizer-cmp.nvim",
    -- },
    config = function()
      local cmp = require("cmp")
      local tailwind_colorizer = require("tailwindcss-colorizer-cmp").formatter

      cmp.setup({
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body) -- For Luasnip users.
          end,
        },
        mapping = {
          ["<C-Space>"] = cmp.mapping.complete(), -- Manually trigger completion
          ["<CR>"] = cmp.mapping.confirm({ select = false }), -- Confirm the first suggestion
          ["<Down>"] = cmp.mapping.select_next_item(), -- Navigate to next item
          ["<Up>"] = cmp.mapping.select_prev_item(), -- Navigate to previous item
          ["<C-e>"] = cmp.mapping.abort(), -- Close the completion window
        },
        sources = cmp.config.sources({
          { name = "nvim_lsp" }, -- LSP completions
          { name = "buffer" }, -- Buffer completions
          { name = "path" }, -- Path completions
          { name = "luasnip" }, -- Snippet completions
        }),
        formatting = {
          fields = { "abbr", "kind", "menu" },
          expandable_indicator = true,
          format = function(entry, item)
            item = tailwind_colorizer(entry, item)
            item.menu = ({
              nvim_lsp = "[LSP]",
              buffer = "[Buffer]",
              path = "[Path]",
              luasnip = "[Snippet]",
            })[entry.source.name]
            return item
          end,
        },
      })

      -- Set up cmdline completion
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = "path" },
          { name = "cmdline" },
        },
      })
    end,
  },
```

# === ASSISTANT ===

You're absolutely correct that the type of completion you're referring to is called "buffer" completions. In your `nvim-cmp` configuration, the `buffer` source is responsible for providing completions based on the text in the current file (or other open buffers, depending on the setup). This can indeed cause performance issues with large files like Markdown documents, as it scans the buffer content for suggestions.

To disable buffer completions entirely, you can simply remove the `buffer` source from your `nvim-cmp` configuration. I'll guide you through how to do this and address any potential concerns.

---

### Why Buffer Completions Cause Slowness
The `buffer` source in `nvim-cmp` indexes words from the current buffer (and sometimes other buffers) to provide completions. For large Markdown files, this means scanning thousands of lines of text, which can lead to noticeable lag during typing or completion triggering.

---

### How to Disable Buffer Completions
In your provided configuration, the `buffer` source is explicitly included in the `sources` table:

```lua
sources = cmp.config.sources({
  { name = "nvim_lsp" }, -- LSP completions
  { name = "buffer" },   -- Buffer completions
  { name = "path" },     -- Path completions
  { name = "luasnip" },  -- Snippet completions
}),
```

To disable buffer completions, simply remove the `{ name = "buffer" }` entry. Here's the updated section of your config:

```lua
sources = cmp.config.sources({
  { name = "nvim_lsp" }, -- LSP completions
  { name = "path" },     -- Path completions
  { name = "luasnip" },  -- Snippet completions
}),
```

This will prevent `nvim-cmp` from suggesting completions based on the content of any buffers.

---

### Alternative: Disable Buffer Completions for Specific Filetypes
If you want to keep buffer completions for some filetypes (e.g., small code files) but disable them for Markdown or large files, you can use `nvim-cmp`'s filetype-specific configuration. For example:

```lua
cmp.setup.filetype("markdown", {
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "path" },
    { name = "luasnip" },
  }),
})
```

This snippet overrides the sources for Markdown files, excluding the `buffer` source, while keeping it enabled for other filetypes. Add this right after your main `cmp.setup()` call.

You can also apply this to multiple filetypes by passing a table of filetypes:

```lua
cmp.setup.filetype({ "markdown", "text" }, {
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "path" },
    { name = "luasnip" },
  }),
})
```

---

### Verifying the Change
After updating your configuration:
1. Restart Neovim to apply the changes.
2. Open a large Markdown file.
3. Type something and trigger completion (e.g., with `<C-Space>`).
4. Check if completions from the buffer content no longer appear. You should only see suggestions from `nvim_lsp`, `path`, and `luasnip`.

Additionally, since you've removed the `buffer` source, the `[Buffer]` label in the completion menu (from your `formatting.format` function) won't appear anymore. If you want to keep the formatting clean, you can also remove the `buffer = "[Buffer]"` line from the `menu` table in your `formatting` section, like so:

```lua
formatting = {
  fields = { "abbr", "kind", "menu" },
  expandable_indicator = true,
  format = function(entry, item)
    item = tailwind_colorizer(entry, item)
    item.menu = ({
      nvim_lsp = "[LSP]",
      path = "[Path]",
      luasnip = "[Snippet]",
    })[entry.source.name]
    return item
  end,
},
```

---

### Additional Performance Tips
If you still experience slowness with large Markdown files, consider the following:
1. **Disable LSP for Markdown if unnecessary**: If you don't need LSP features (e.g., diagnostics or completions) for Markdown, you can disable the LSP source for Markdown filetypes similarly to the above method.
   ```lua
   cmp.setup.filetype("markdown", {
     sources = cmp.config.sources({
       { name = "path" },
       { name = "luasnip" },
     }),
   })
   ```
2. **Adjust `nvim-cmp` performance settings**: You can tweak settings like `performance.debounce` or `performance.throttle` in `cmp.setup()` to reduce the frequency of completion updates.
   ```lua
   performance = {
     debounce = 60, -- Delay before updating completions (ms)
     throttle = 30, -- Delay between updates during typing (ms)
   },
   ```
3. **Use `vim.b.omnifunc` for minimal completion**: If you don't need `nvim-cmp` at all for Markdown, you can disable it entirely for specific filetypes by setting up an autocommand to turn off `nvim-cmp` or revert to Vim's default completion.
   ```lua
   vim.api.nvim_create_autocmd("FileType", {
     pattern = "markdown",
     callback = function()
       require("cmp").setup.buffer({ enabled = false })
     end,
   })
   ```

---

### Final Updated Config (Minimal Change)
Here’s your config with the `buffer` source removed globally:

```lua
{
  "hrsh7th/nvim-cmp",
  -- dependencies = {
  --   "roobert/tailwindcss-colorizer-cmp.nvim",
  -- },
  config = function()
    local cmp = require("cmp")
    local tailwind_colorizer = require("tailwindcss-colorizer-cmp").formatter

    cmp.setup({
      snippet = {
        expand = function(args)
          require("luasnip").lsp_expand(args.body) -- For Luasnip users.
        end,
      },
      mapping = {
        ["<C-Space>"] = cmp.mapping.complete(), -- Manually trigger completion
        ["<CR>"] = cmp.mapping.confirm({ select = false }), -- Confirm the first suggestion
        ["<Down>"] = cmp.mapping.select_next_item(), -- Navigate to next item
        ["<Up>"] = cmp.mapping.select_prev_item(), -- Navigate to previous item
        ["<C-e>"] = cmp.mapping.abort(), -- Close the completion window
      },
      sources = cmp.config.sources({
        { name = "nvim_lsp" }, -- LSP completions
        { name = "path" },     -- Path completions
        { name = "luasnip" },  -- Snippet completions
      }),
      formatting = {
        fields = { "abbr", "kind", "menu" },
        expandable_indicator = true,
        format = function(entry, item)
          item = tailwind_colorizer(entry, item)
          item.menu = ({
            nvim_lsp = "[LSP]",
            path = "[Path]",
            luasnip = "[Snippet]",
          })[entry.source.name]
          return item
        end,
      },
    })

    -- Set up cmdline completion
    cmp.setup.cmdline(":", {
      mapping = cmp.mapping.preset.cmdline(),
      sources = {
        { name = "path" },
        { name = "cmdline" },
      },
    })
  end,
},
```

---

### Conclusion
By removing the `buffer` source or disabling it for specific filetypes like Markdown, you should see a significant performance improvement in large files. If you have any other issues or want to fine-tune this further (e.g., conditional sources based on file size), let me know!

# === USER ===



the latest version of neovim has started "compacting" my markdown and lua files (and maybe others). i forget what this is called, but it will basically replace a function with a line that i have to expand by pressing zO. what is this called? what is the command i can press to "expand" the entire file? i think it is called "folding" or something like that.

# === ASSISTANT ===

Yes, you're correct that this feature is called **folding** in Neovim (and Vim). Folding allows you to collapse sections of code or text (like functions, blocks, or headings) into a single line, which can then be expanded when needed. This is particularly useful for navigating large files or focusing on specific parts of your code.

### What You're Experiencing
Neovim's latest versions may have enabled folding by default for certain filetypes (like Markdown and Lua) through built-in or plugin configurations (e.g., `treesitter` or `lsp`). When a section is folded, it appears as a single line with a marker (e.g., `▶`), and you can expand it by pressing `zO` (as you mentioned).

### Key Terms and Commands
- **Folding**: The mechanism to collapse/expand sections of text.
- **Folded Line**: A collapsed section represented by a single line.
- **zO**: Expands (opens) the fold under the cursor, including nested folds.
- **zR**: Expands (reduces) all folds in the entire file. This is likely the command you're looking for to "expand" the entire file.
- **zM**: Closes (maximizes) all folds in the entire file, collapsing everything possible.

### How to Expand the Entire File
To expand all folds in the file, use the command:
```
zR
```
- `z` is the prefix for fold-related commands.
- `R` stands for "reduce" folding (i.e., open all folds).

### How to Check/Disable Folding
If you don't want folding to be enabled by default, you can check how it's being set and disable it:
1. **Check if folding is enabled**:
   Run the following command to see the current fold settings for the buffer:
   ```
   :set foldmethod?
   ```
   Common values are:
   - `manual`: Folds are created manually.
   - `indent`: Folds based on indentation (common for Lua).
   - `syntax`: Folds based on syntax rules.
   - `expr`: Folds based on an expression (often used with Treesitter or LSP).
   - `marker`: Folds based on specific markers in the text.

2. **Disable folding for the current session**:
   ```
   :set nofoldenable
   ```
   This turns off folding temporarily for the current buffer.

3. **Disable folding permanently**:
   Add the following to your Neovim configuration file (usually `~/.config/nvim/init.lua` or `~/.config/nvim/init.vim`):
   ```lua
   vim.opt.foldenable = false
   ```
   This disables folding by default for all files.

4. **Check if a plugin or Treesitter is enabling folding**:
   If you're using Neovim's built-in Treesitter or LSP features, they might be setting up folding automatically. For example, Treesitter folding is often enabled with `foldmethod=expr` and `foldexpr=nvim_treesitter#foldexpr()`. You can disable this by overriding the settings in your config:
   ```lua
   vim.opt.foldmethod = 'manual'
   vim.opt.foldenable = false
   ```

### Useful Fold Commands
Here are some additional fold-related commands that might help:
- `zo`: Open the fold under the cursor (one level).
- `zc`: Close the fold under the cursor (one level).
- `za`: Toggle the fold under the cursor (open if closed, close if open).
- `zM`: Close all folds in the file (maximize folding).
- `zR`: Open all folds in the file (reduce folding).

### Why Is This Happening in the Latest Version?
Neovim 0.10 (released in May 2024) introduced improvements to Treesitter and LSP integrations, and some configurations or plugins might enable folding by default for better code navigation. If you recently updated Neovim or a plugin (like `nvim-treesitter`), this could explain the change. Check your configuration or plugin settings if you want to customize or disable folding.

If you have further questions or want help with a specific setup, let me know!

# === USER ===

thanks. this is weird. the folding is only happening for markdown and lua files. it doesn't seem to happen for other file types. and for lua, it is more advanced, giving me a special line next to each function. in fact, i can't fold typescript or zsh files. is this a configuration issue with one of my plugins? i forget if i ever installed some folding plugin. is there a way to enable/disable folding for specific file types?

# === ASSISTANT ===

I'm glad I could help with the basics of folding! The behavior you're describing—folding happening only for Markdown and Lua files, with Lua showing "special lines" next to functions, and no folding for TypeScript or Zsh—strongly suggests that this is related to a plugin or Neovim's built-in features like Treesitter or LSP, which are configured to enable folding for specific filetypes. Let's break this down and address your questions systematically.

### Why Folding Happens Only for Markdown and Lua
Folding in Neovim is often filetype-specific because:
1. **Treesitter or LSP Integration**: Neovim's built-in support for Treesitter (a syntax parsing library) and LSP (Language Server Protocol) can enable folding based on the syntax or structure of specific languages. Treesitter, for instance, is commonly used for Lua (Neovim's configuration language) and Markdown, and it provides advanced folding capabilities (like folding functions or blocks with "special lines" showing summaries).
2. **Filetype-Specific Autocommands or Plugins**: Some plugins or configurations in your setup might apply folding settings only to certain filetypes (e.g., `markdown` and `lua`) via autocommands or filetype-specific scripts.
3. **Default Fold Settings**: Neovim or a plugin might set `foldmethod` (e.g., `expr` for Treesitter-based folding) for specific filetypes, while leaving others (like TypeScript or Zsh) with `foldmethod=manual` or no folding support.

The "special line" next to functions in Lua files is likely a fold summary provided by Treesitter or a plugin like `nvim-treesitter`. This feature shows a compact representation of the folded content (e.g., the function signature) and is a hallmark of Treesitter-based folding with `foldmethod=expr`.

### Why Folding Isn't Happening for TypeScript or Zsh
- **TypeScript**: If you have Treesitter or LSP installed for TypeScript (e.g., via `nvim-treesitter` or a language server like `tsserver`), folding might not be enabled by default, or the fold settings might not be applied. Alternatively, your configuration might lack the necessary Treesitter parser or fold expressions for TypeScript.
- **Zsh**: Shell scripts like Zsh often don't have advanced folding support out of the box in Neovim, as Treesitter or syntax files for shell scripts may not define foldable structures (e.g., functions or blocks) by default. Folding for shell scripts typically requires manual setup or a specific plugin.

### Is This a Configuration Issue with a Plugin?
It's not necessarily an "issue" but rather a result of how your Neovim setup is configured. You might have a plugin or built-in feature enabling folding for Markdown and Lua, such as:
- **`nvim-treesitter`**: A popular plugin for syntax highlighting and folding, which supports Lua and Markdown out of the box and often enables folding via `foldmethod=expr`.
- **LSP**: If you have language servers set up for Lua (e.g., `lua_ls`) or Markdown, they might provide folding ranges.
- **Built-in Filetype Scripts**: Neovim's default filetype plugins (e.g., for Markdown) might set folding based on headings or syntax.
- **Custom Config or Other Plugins**: You might have a folding plugin (like `vim-fold` or `fold-cycle.nvim`) or custom autocommands in your `init.lua`/`init.vim` that apply folding to specific filetypes.

To check if a plugin is responsible:
1. Run `:set foldmethod?` in a Markdown or Lua file to see how folding is being set (e.g., `expr` often indicates Treesitter or custom expressions).
2. Use `:verbose set foldmethod?` to see where the setting was last defined (e.g., a plugin or your config file).
3. Check your plugin list with `:Plug` (if using vim-plug) or look in your `init.lua` for mentions of folding or Treesitter. Common culprits are `nvim-treesitter` or lines setting `vim.opt.foldmethod`.

### How to Enable/Disable Folding for Specific Filetypes
Yes, you can control folding on a per-filetype basis using Neovim's autocommands or filetype-specific settings. Here’s how to do it:

#### Disable Folding for Specific Filetypes
To disable folding for Markdown and Lua while leaving it unchanged for others, add the following to your `init.lua` (Lua config) or `init.vim` (Vimscript config):

**Lua (for `init.lua`):**
```lua
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "lua" },
  callback = function()
    vim.opt_local.foldenable = false
  end,
})
```

**Vimscript (for `init.vim`):**
```vim
autocmd FileType markdown,lua setlocal nofoldenable
```

This sets `nofoldenable` only for Markdown and Lua files, preventing folding from being activated.

#### Enable Folding for Specific Filetypes
To enable folding for TypeScript or Zsh (or any other filetype), you can define a `foldmethod` and ensure the necessary support (like Treesitter parsers) is in place. For example:

**Lua (for `init.lua`):**
```lua
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "typescript", "zsh" },
  callback = function()
    vim.opt_local.foldenable = true
    vim.opt_local.foldmethod = "indent" -- or "syntax" if supported
  end,
})
```

**Vimscript (for `init.vim`):**
```vim
autocmd FileType typescript,zsh setlocal foldenable foldmethod=indent
```

- For **TypeScript**, using `foldmethod=expr` with `nvim-treesitter` is better if you have the parser installed. Install the parser with `:TSInstall typescript` and ensure folding is enabled in your Treesitter config (see below).
- For **Zsh**, `foldmethod=indent` or `foldmethod=marker` (if you add markers like `{{{` and `}}}`) might work, as shell scripts don't always have robust syntax folding.

#### Using Treesitter for Folding (Recommended for Code)
If you’re using `nvim-treesitter`, you can enable folding for supported languages like TypeScript by ensuring the parser is installed and setting up folding in your config. Add or modify the following in your `init.lua`:

```lua
require('nvim-treesitter.configs').setup {
  ensure_installed = { "lua", "markdown", "typescript" }, -- Add languages you want
  fold = {
    enable = true, -- Enable folding module
  },
}
-- Optionally, set foldmethod globally or per-filetype
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldenable = true
```

Then, install the necessary parsers with `:TSInstall typescript` or `:TSInstallAll`. This will enable advanced folding for TypeScript (similar to Lua's "special lines").

To disable Treesitter folding for specific filetypes while keeping it for others, you can override `foldenable` or `foldmethod` using autocommands as shown above.

### Steps to Investigate Your Setup
1. **Check Fold Settings per Filetype**:
   Open a Markdown, Lua, TypeScript, and Zsh file, and in each, run:
   ```
   :set foldmethod?
   :set foldenable?
   :verbose set foldmethod?
   ```
   This will show how folding is configured and where the setting comes from.

2. **Check for Treesitter**:
   If you see `foldmethod=expr` and references to `nvim_treesitter#foldexpr()`, Treesitter is likely enabling folding. Check if `nvim-treesitter` is installed by looking in your plugin list or config.

3. **Search Your Config**:
   Search your `init.lua` or `init.vim` for terms like `fold`, `foldmethod`, `foldenable`, or `treesitter` to see if you’ve explicitly configured folding.

4. **Temporarily Disable Plugins**:
   If you suspect a plugin, start Neovim with minimal plugins (e.g., `nvim --clean`) to see if folding persists. If it stops, a plugin is responsible, and you can re-enable plugins one by one to identify the culprit.

### Summary
- The folding for Markdown and Lua is likely due to `nvim-treesitter`, LSP, or a filetype-specific setting in Neovim.
- Folding isn’t enabled for TypeScript or Zsh because their fold settings (e.g., `foldmethod`) or Treesitter parsers might not be configured.
- You can enable/disable folding per filetype using autocommands as shown above.
- If using Treesitter, ensure parsers are installed for languages like TypeScript (`:TSInstall typescript`) and enable the fold module in your config.

If you’d like help with a specific part of your config or want to share snippets to debug, let me know, and I can assist further!

# === USER ===

here is my tree sitter config. notice i have an "object" plugin i use extensively. do you see anything wrong with this config that would cause folding to only work with lua and markdown?

```lua
  -- Treesitter for syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    -- dependencies = {
    --   "LhKipp/nvim-nu",
    -- },
    run = ":TSUpdate",
  },

  -- Treesitter for syntax highlighting and text-objects for selecting markdown code blocks
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    dependencies = { "nvim-treesitter/nvim-treesitter", "LhKipp/nvim-nu" },
    run = ":TSUpdate",
    config = function()
      ---@diagnostic disable-next-line: missing-fields
      require("nvim-treesitter.configs").setup({
        -- Install parsers for various languages
        ensure_installed = {
          "css",
          "html",
          "javascript",
          "jsdoc",
          "json",
          "jsonc",
          "lua",
          "markdown",
          "markdown_inline",
          "nu",
          "python",
          "rust",
          "toml",
          "tsx",
          "typescript",
          "wgsl",
          "yaml",
        }, -- Add more languages as needed

        -- Enable Treesitter-based syntax highlighting
        highlight = {
          enable = true, -- Enable Treesitter highlighting
          additional_vim_regex_highlighting = false, -- Disable Vim's regex-based highlighting
        },

        -- You can enable more Treesitter features as needed (optional)
        indent = { enable = false }, -- Enable Treesitter-based indentation (optional)

        -- Folding
        fold = { enable = true }, -- Enable Treesitter-based folding (optional)

        -- Required for nvim-treesitter-textobjects
        textobjects = {
          select = {
            enable = true,
            lookahead = true, -- Automatically jump forward to textobj if cursor is outside
            keymaps = {
              -- Define a custom text object for markdown fenced code blocks
              ["ic"] = {
                query = "@codeblock.inner",
                desc = "Select inside markdown code block",
              },
              ["ac"] = {
                query = "@codeblock.outer",
                desc = "Select around markdown code block",
              },
              ["if"] = {
                query = "@function.inner",
                desc = "Select inside function (TypeScript, etc.)",
              },
              ["af"] = {
                query = "@function.outer",
                desc = "Select around function (TypeScript, etc.)",
              },
              ["ik"] = {
                query = "@class.inner",
                desc = "Select inside class (TypeScript, etc.)",
              },
              ["ak"] = {
                query = "@class.outer",
                desc = "Select around class (TypeScript, etc.)",
              },
            },
            -- Optionally, configure selection modes or other settings
            selection_modes = {
              ["@codeblock.inner"] = "V", -- Use linewise visual mode for inner selection
              ["@codeblock.outer"] = "V", -- Use linewise visual mode for outer selection
              ["@function.inner"] = "V",
              ["@function.outer"] = "V",
              ["@class.inner"] = "V",
              ["@class.outer"] = "V",
            },
          },
          move = {
            enable = true,
            set_jumps = true, -- Add to jump list for navigation history
            goto_next_start = {
              ["]c"] = {
                query = "@codeblock.outer",
                desc = "Next code block start",
              },
              ["]f"] = {
                query = "@function.outer",
                desc = "Next function start",
              },
              ["]k"] = { query = "@class.outer", desc = "Next class start" },
            },
            goto_next_end = {
              ["]C"] = {
                query = "@codeblock.outer",
                desc = "Next code block end",
              },
            },
            goto_previous_start = {
              ["[c"] = {
                query = "@codeblock.outer",
                desc = "Previous code block start",
              },
              ["[f"] = {
                query = "@function.outer",
                desc = "Previous function start",
              },
              ["[k"] = { query = "@class.outer", desc = "Previous class start" },
            },
            goto_previous_end = {
              ["[C"] = {
                query = "@codeblock.outer",
                desc = "Previous code block end",
              },
            },
          },
        },
      })

      -- Define the custom Tree-sitter queries for markdown code blocks
      vim.treesitter.query.set(
        "markdown",
        "textobjects",
        [[
      (fenced_code_block
        (code_fence_content) @codeblock.inner
      ) @codeblock.outer
    ]]
      )
    end,
  },

```

# === ASSISTANT ===

Thanks for sharing your Treesitter configuration! Let's analyze it to understand why folding is only working for Lua and Markdown, and not for other filetypes like TypeScript or Zsh, as well as address any potential issues or misconfigurations.

### Analysis of Your Treesitter Config
1. **Treesitter Setup and Folding**:
   - You have `nvim-treesitter` and `nvim-treesitter-textobjects` installed, which are correctly set up with a list of parsers for multiple languages, including `lua`, `markdown`, `markdown_inline`, `typescript`, `tsx`, and others.
   - You have explicitly enabled Treesitter-based folding with `fold = { enable = true }` in your configuration. This tells Treesitter to provide folding capabilities for supported languages.
   - However, enabling folding in the Treesitter config alone is not sufficient to activate folding in Neovim. Treesitter provides the fold expressions (via `foldexpr`), but Neovim must also have `foldmethod=expr` and `foldenable=true` set for the buffer to actually use folding. If these options are not set globally or per-filetype, folding won't be active, even with Treesitter's `fold.enable = true`.

2. **Missing Foldmethod and Foldexpr Setup**:
   - In your config, you haven't explicitly set `vim.opt.foldmethod = "expr"` or `vim.opt.foldexpr = "nvim_treesitter#foldexpr()"` (or equivalent). These settings are necessary to tell Neovim to use Treesitter's folding logic. Without them, even though `fold = { enable = true }` is set in Treesitter, Neovim might not apply folding or might fall back to a different `foldmethod` (like `manual` or `indent`) for some filetypes.
   - It's possible that for Lua and Markdown, Neovim or another part of your config (or a plugin) is setting `foldmethod=expr` implicitly, or Treesitter folding is being applied due to default filetype settings in Neovim. For other filetypes like TypeScript or Zsh, these settings might not be applied, resulting in no folding.

3. **Supported Filetypes for Folding**:
   - Treesitter folding works best for languages where the parser defines foldable structures (like functions, classes, or blocks). For `lua` and `markdown`, Treesitter has well-defined fold queries (e.g., folding functions in Lua or headings/code blocks in Markdown), so folding works out of the box when `foldmethod=expr` is set.
   - For `typescript` and `tsx`, Treesitter also supports folding (e.g., for functions and classes, as seen in your `textobjects` keymaps), but if `foldmethod=expr` isn't set for those filetypes, folding won't activate.
   - For `zsh` (which isn't in your `ensure_installed` list), Treesitter folding isn't enabled by default, and shell script parsers often don't define complex fold structures. You’d need to install the `bash` or `zsh` parser (via `:TSInstall bash`) and set up folding manually if desired.

4. **Textobjects and Folding**:
   - Your `textobjects` configuration is extensive and well-defined for selecting and moving between code blocks, functions, and classes. This part of the config is unrelated to folding and looks correct. It shows that Treesitter is working for languages like TypeScript (since you have keymaps for `@function.inner` and `@class.outer`), but folding depends on separate settings.

5. **No Obvious Errors**:
   - There’s nothing inherently "wrong" with your config that would cause folding to work only for Lua and Markdown. Instead, the issue likely stems from missing global or filetype-specific settings for `foldmethod` and `foldexpr`, or Neovim's default behavior applying folding differently based on filetype.

### Why Folding Only Works for Lua and Markdown
- **Lua**: As Neovim's configuration language, Lua often gets special treatment. Neovim's default filetype settings or Treesitter might set `foldmethod=expr` automatically for Lua files. Additionally, since Lua is used in your `init.lua`, Treesitter folding might be activated by default during initialization.
- **Markdown**: Markdown folding (e.g., for headings or code blocks) is well-supported by Treesitter with the `markdown` and `markdown_inline` parsers. Neovim or Treesitter might apply `foldmethod=expr` for Markdown by default, especially since you have custom textobjects for code blocks.
- **TypeScript/TSX**: Even though the parsers are installed and textobjects are defined, folding isn't active because `foldmethod=expr` might not be set for these filetypes. Neovim doesn't enable Treesitter folding automatically for all languages unless explicitly configured.
- **Zsh**: The parser isn't installed (not in `ensure_installed`), and shell scripts don't typically have folding defined by default in Treesitter or Neovim.

### How to Fix/Extend Folding to Other Filetypes
To ensure folding works consistently across filetypes or to disable it for specific ones, you need to explicitly set the folding options in Neovim. Here are the steps and configurations to add:

#### 1. Set Global Folding Options for Treesitter
Add the following to your `init.lua` (outside the `require("nvim-treesitter.configs").setup` block) to enable Treesitter folding globally for all supported filetypes:

```lua
-- Enable Treesitter-based folding
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldenable = true
vim.opt.foldlevelstart = 99 -- Start with all folds open (adjust as needed)
```

- `foldmethod = "expr"` tells Neovim to use an expression for folding, which Treesitter provides.
- `foldexpr = "nvim_treesitter#foldexpr()"` links Neovim's folding to Treesitter's logic.
- `foldenable = true` ensures folding is turned on.
- `foldlevelstart = 99` (optional) starts with all folds expanded (a high number means deeper folds are open by default).

With this, folding should work for all filetypes in your `ensure_installed` list that support folding in Treesitter (e.g., TypeScript, Lua, Markdown, etc.).

#### 2. Enable Folding for Zsh (Optional)
To enable folding for Zsh or shell scripts:
- Add the `bash` parser (used for shell scripts like Zsh) to your `ensure_installed` list:
  ```lua
  ensure_installed = {
    "css", "html", "javascript", "jsdoc", "json", "jsonc", "lua",
    "markdown", "markdown_inline", "nu", "python", "rust", "toml",
    "tsx", "typescript", "wgsl", "yaml", "bash" -- Add bash for Zsh/shell
  },
  ```
- Install the parser with `:TSInstall bash`.
- Since Treesitter's `bash` parser might not define complex folds by default, you can fall back to `foldmethod=indent` or define custom fold expressions if needed (see below for filetype-specific settings).

#### 3. Disable Folding for Specific Filetypes (e.g., Lua and Markdown)
If you want to keep folding enabled globally but disable it for Lua and Markdown, use autocommands:

```lua
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "lua", "markdown" },
  callback = function()
    vim.opt_local.foldenable = false
  end,
})
```

#### 4. Enable Folding for Specific Filetypes with Custom Methods
If you don’t want global folding or Treesitter folding for all filetypes, you can set folding per filetype. For example:

```lua
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "typescript", "tsx", "javascript" },
  callback = function()
    vim.opt_local.foldmethod = "expr"
    vim.opt_local.foldexpr = "nvim_treesitter#foldexpr()"
    vim.opt_local.foldenable = true
    vim.opt_local.foldlevelstart = 99 -- Start with folds open
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "zsh", "sh" },
  callback = function()
    vim.opt_local.foldmethod = "indent" -- Use indent-based folding for shell scripts
    vim.opt_local.foldenable = true
    vim.opt_local.foldlevelstart = 99
  end,
})
```

#### 5. Debugging Current Behavior
To confirm why folding is only active for Lua and Markdown, open files of different types and run:
- `:set foldmethod?`
- `:set foldexpr?`
- `:set foldenable?`
- `:verbose set foldmethod?`

If `foldmethod=expr` and `foldexpr=nvim_treesitter#foldexpr()` are set for Lua and Markdown but not for TypeScript or Zsh, it confirms that another part of your config or Neovim's defaults are setting these options selectively.

### Additional Notes
- **Object Plugin**: You mentioned an "object" plugin, which I assume refers to `nvim-treesitter-textobjects`. This plugin is unrelated to folding; it only handles text object selections and movements (e.g., `ic`, `af`). It doesn't influence why folding works for some filetypes and not others.
- **Treesitter Version**: Ensure your Treesitter parsers are up to date with `:TSUpdate`. Older parsers might not support folding for certain languages.
- **Neovim Version**: If you're on an older Neovim version (pre-0.9 or 0.10), Treesitter folding behavior might differ. Use `:version` to check, and consider updating if needed.

### Recommended Config Update
Here’s how I’d update your config to enable folding consistently for all supported languages while allowing customization:

```lua
require("nvim-treesitter.configs").setup({
  ensure_installed = {
    "css", "html", "javascript", "jsdoc", "json", "jsonc", "lua",
    "markdown", "markdown_inline", "nu", "python", "rust", "toml",
    "tsx", "typescript", "wgsl", "yaml", "bash" -- Added for shell scripts
  },
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  indent = { enable = false },
  fold = { enable = true }, -- Enable Treesitter folding
  textobjects = {
    select = {
      enable = true,
      lookahead = true,
      keymaps = {
        ["ic"] = { query = "@codeblock.inner", desc = "Select inside markdown code block" },
        ["ac"] = { query = "@codeblock.outer", desc = "Select around markdown code block" },
        ["if"] = { query = "@function.inner", desc = "Select inside function" },
        ["af"] = { query = "@function.outer", desc = "Select around function" },
        ["ik"] = { query = "@class.inner", desc = "Select inside class" },
        ["ak"] = { query = "@class.outer", desc = "Select around class" },
      },
      selection_modes = {
        ["@codeblock.inner"] = "V", ["@codeblock.outer"] = "V",
        ["@function.inner"] = "V", ["@function.outer"] = "V",
        ["@class.inner"] = "V", ["@class.outer"] = "V",
      },
    },
    move = {
      enable = true,
      set_jumps = true,
      goto_next_start = {
        ["]c"] = { query = "@codeblock.outer", desc = "Next code block start" },
        ["]f"] = { query = "@function.outer", desc = "Next function start" },
        ["]k"] = { query = "@class.outer", desc = "Next class start" },
      },
      goto_next_end = {
        ["]C"] = { query = "@codeblock.outer", desc = "Next code block end" },
      },
      goto_previous_start = {
        ["[c"] = { query = "@codeblock.outer", desc = "Previous code block start" },
        ["[f"] = { query = "@function.outer", desc = "Previous function start" },
        ["[k"] = { query = "@class.outer", desc = "Previous class start" },
      },
      goto_previous_end = {
        ["[C"] = { query = "@codeblock.outer", desc = "Previous code block end" },
      },
    },
  },
})

-- Enable Treesitter folding globally
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldenable = true
vim.opt.foldlevelstart = 99 -- Start with all folds open

-- Optional: Disable folding for Lua and Markdown if desired
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "lua", "markdown" },
  callback = function()
    -- vim.opt_local.foldenable = false -- Uncomment to disable folding for these
  end,
})

-- Optional: Custom folding for shell scripts (Zsh/Sh)
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "zsh", "sh" },
  callback = function()
    vim.opt_local.foldmethod = "indent" -- Fallback for shell scripts
    vim.opt_local.foldenable = true
    vim.opt_local.foldlevelstart = 99
  end,
})
```

### Summary
- Your config enables Treesitter folding with `fold = { enable = true }`, but lacks the necessary `foldmethod=expr` and `foldexpr` settings to activate it across all filetypes.
- Lua and Markdown likely have folding due to Neovim defaults or implicit settings elsewhere in your setup.
- Add the global folding options or use autocommands to enable folding for TypeScript and other languages.
- For Zsh, install the `bash` parser and use a fallback like `foldmethod=indent`.

If you apply the above changes and still face issues, or if folding behavior doesn’t match expectations, let me know the output of `:set foldmethod?` and `:set foldexpr?` for different filetypes, and I’ll help debug further!

# === USER ===

there is apparently no tresitter parser for zsh, at least not by default. is there any fix for this? isn't zsh very popular? is there another plugin i need?

# === ASSISTANT ===

You're correct that there is no dedicated Treesitter parser for Zsh by default in the `nvim-treesitter` plugin. While Zsh (Z Shell) is indeed a very popular shell among developers, especially in the Unix/Linux/macOS communities, Treesitter parser support for it is not as straightforward as for programming languages like Lua or TypeScript. Let's explore why this is the case, whether there's a fix, and alternative approaches to enable folding or syntax support for Zsh in Neovim.

### Why No Default Treesitter Parser for Zsh?
1. **Treesitter Parser Availability**:
   - The `nvim-treesitter` plugin relies on Tree-sitter, a parsing library that provides syntax trees for various languages. While Tree-sitter has parsers for many programming languages and markup formats, shell scripting languages like Zsh don't have a dedicated parser in the core Tree-sitter repository or in `nvim-treesitter`'s default list.
   - Instead, Tree-sitter offers a `bash` parser (since Bash is the most widely used shell and shares syntax similarities with Zsh). This parser can often handle Zsh scripts to some extent because Zsh is largely compatible with Bash syntax, though Zsh has additional features and extensions that the `bash` parser might not fully support.

2. **Community Focus**:
   - Tree-sitter and `nvim-treesitter` development tends to prioritize languages with broader usage in programming (e.g., Python, JavaScript) or specific editor integrations (e.g., Lua for Neovim). While Zsh is popular as an interactive shell, it’s less commonly used for complex scripting compared to Bash, so a dedicated parser hasn’t been a high priority for the community.
   - That said, there are community efforts to improve shell script parsing, and you can sometimes find third-party or experimental parsers for Zsh.

### Is There a Fix for Zsh Support in Treesitter?
Yes, there are a few approaches to get syntax highlighting and potentially folding for Zsh using Treesitter or other methods in Neovim. Since there’s no official Zsh parser by default, here are your options:

#### 1. Use the `bash` Parser as a Substitute
The `bash` parser provided by `nvim-treesitter` can be used for Zsh files since much of Zsh syntax overlaps with Bash. This won’t cover all Zsh-specific features (like certain built-ins or extended globbing), but it’s often good enough for basic syntax highlighting and possibly folding.

**Steps to Use the `bash` Parser for Zsh:**
- Add `bash` to your `ensure_installed` list in your `nvim-treesitter` configuration if it’s not already there:
  ```lua
  require("nvim-treesitter.configs").setup({
    ensure_installed = {
      "bash", -- Add bash for shell scripts including Zsh
      "lua",
      "markdown",
      -- other languages...
    },
    highlight = { enable = true },
    fold = { enable = true },
    -- other settings...
  })
  ```
- Install the parser with:
  ```
  :TSInstall bash
  ```
- Map the `bash` parser to Zsh filetypes in Neovim by setting the filetype detection to use the `bash` parser for `.zsh` files or other Zsh-related files. Add this to your `init.lua`:
  ```lua
  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "zsh" },
    callback = function()
      vim.treesitter.start(nil, "bash") -- Force Treesitter to use bash parser for zsh
      vim.opt_local.foldmethod = "expr"
      vim.opt_local.foldexpr = "nvim_treesitter#foldexpr()"
      vim.opt_local.foldenable = true
      vim.opt_local.foldlevelstart = 99
    end,
  })
  ```
  Alternatively, if `vim.treesitter.start(nil, "bash")` doesn’t work in older Neovim versions, you can set the filetype to `sh` (which often uses Bash parsing) for Zsh files:
  ```lua
  vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
    pattern = {"*.zsh", ".zshrc", ".zshenv"},
    callback = function()
      vim.bo.filetype = "sh" -- Treat Zsh files as shell scripts (uses bash parser)
    end,
  })
  ```

**Limitations**: The `bash` parser won’t fully support Zsh-specific syntax (e.g., `zstyle` commands or advanced Zsh arrays). Folding might be rudimentary since the parser isn’t tailored for Zsh structures, but it can still work for basic blocks or indentation.

#### 2. Check for Community or Third-Party Zsh Parsers
While there’s no official Zsh parser in `nvim-treesitter`, the Tree-sitter community sometimes maintains third-party parsers. You can check the Tree-sitter GitHub organization or community repositories for a Zsh parser and integrate it into `nvim-treesitter`.

**Steps to Add a Third-Party Parser**:
- Search for a Zsh parser on GitHub (e.g., look for `tree-sitter-zsh` or check the Tree-sitter parser list at https://github.com/tree-sitter/tree-sitter).
- If you find one (e.g., a repository like `tree-sitter-zsh`), you can manually add it to `nvim-treesitter` by extending the parser list in your config. Follow the `nvim-treesitter` documentation for custom parsers:
  ```lua
  local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
  parser_config.zsh = {
    install_info = {
      url = "https://github.com/user/tree-sitter-zsh", -- Replace with actual repo URL
      files = {"src/parser.c"},
      branch = "main",
    },
    filetype = "zsh",
  }
  ```
- Add `zsh` to `ensure_installed`:
  ```lua
  ensure_installed = { "bash", "zsh", "lua", -- other languages... }
  ```
- Install with `:TSInstall zsh`.

**Note**: As of my last update (October 2023), there isn’t a widely recognized or maintained Zsh parser in the Tree-sitter ecosystem, but this could change. Check the latest community resources or the `nvim-treesitter` issue tracker for updates.

#### 3. Use Non-Treesitter Folding for Zsh
Since Treesitter support for Zsh is limited, you can fall back to Neovim’s built-in folding methods, such as `indent` or `marker`, which don’t rely on Treesitter. These methods can still be effective for shell scripts.

**Option A: Indent-Based Folding**
- Use `foldmethod=indent` to fold based on indentation levels, which works well for shell scripts with nested loops or functions.
  ```lua
  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "zsh", "sh" },
    callback = function()
      vim.opt_local.foldmethod = "indent"
      vim.opt_local.foldenable = true
      vim.opt_local.foldlevelstart = 99 -- Start with folds open
    end,
  })
  ```

**Option B: Marker-Based Folding**
- Use `foldmethod=marker` with custom markers (e.g., `# {{{` and `# }}}`) in your Zsh scripts to define foldable regions manually.
  ```lua
  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "zsh", "sh" },
    callback = function()
      vim.opt_local.foldmethod = "marker"
      vim.opt_local.foldmarker = "{{{,}}}"
      vim.opt_local.foldenable = true
      vim.opt_local.foldlevelstart = 99
    end,
  })
  ```
  In your Zsh scripts, you’d add markers like:
  ```zsh
  # {{{ My Function
  my_function() {
    echo "Hello"
  }
  # }}}
  ```

**Option C: Syntax-Based Folding**
- If Neovim’s syntax file for shell scripts (`sh.vim`) defines foldable regions (some versions do for functions or blocks), you can use `foldmethod=syntax`:
  ```lua
  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "zsh", "sh" },
    callback = function()
      vim.opt_local.foldmethod = "syntax"
      vim.opt_local.foldenable = true
      vim.opt_local.foldlevelstart = 99
    end,
  })
  ```
  Note that `syntax` folding depends on the quality of the shell syntax file in your Neovim installation and might not be very robust for Zsh-specific syntax.

#### 4. Alternative Plugins for Zsh Support
If Treesitter doesn’t meet your needs for Zsh syntax highlighting or folding, you can use other Neovim plugins or built-in features for shell script support:

- **Built-in Syntax Highlighting**: Neovim’s default syntax file for shell scripts (`sh.vim`) supports Bash and can often handle Zsh to some extent. Ensure your filetype detection is set correctly for Zsh files:
  ```lua
  vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
    pattern = {"*.zsh", ".zshrc", ".zshenv"},
    callback = function()
      vim.bo.filetype = "zsh" -- or "sh" if zsh-specific syntax file exists
    end,
  })
  ```
  Some Neovim distributions or configurations include enhanced `zsh.vim` syntax files.

- **Third-Party Syntax Plugins**: Plugins like `vim-polyglot` provide improved syntax highlighting for shell scripts, including Zsh. Install it via your plugin manager:
  ```lua
  { "sheerun/vim-polyglot" }
  ```
  `vim-polyglot` often includes better support for Zsh and can work with Neovim’s built-in folding methods (`indent`, `syntax`, or `marker`).

- **Custom Folding Plugins**: If folding is your primary concern, consider a plugin like `vim-fold` or `fold-cycle.nvim` that allows more flexible fold definitions without relying on Treesitter. These can be configured for shell scripts using patterns or indentation.

### Is Zsh Support Coming to Treesitter?
Zsh’s popularity might eventually lead to a dedicated Tree-sitter parser if the community prioritizes it. You can check the `nvim-treesitter` GitHub issues or the Tree-sitter repository for ongoing discussions or contribute to parser development if you’re inclined. For now, using the `bash` parser or non-Treesitter folding methods is the most practical solution.

### Recommended Approach for Zsh Folding
Given the current state of Treesitter support, I recommend the following for Zsh in Neovim:
1. Install the `bash` parser for basic syntax highlighting:
   ```lua
   ensure_installed = { "bash", -- other languages... }
   ```
   Install with `:TSInstall bash`.
2. Set up filetype detection and use `indent` folding for simplicity:
   ```lua
   vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
     pattern = {"*.zsh", ".zshrc", ".zshenv"},
     callback = function()
       vim.bo.filetype = "zsh"
     end,
   })

   vim.api.nvim_create_autocmd("FileType", {
     pattern = { "zsh" },
     callback = function()
       vim.treesitter.start(nil, "bash") -- Use bash parser for highlighting
       vim.opt_local.foldmethod = "indent" -- Use indent folding
       vim.opt_local.foldenable = true
       vim.opt_local.foldlevelstart = 99
     end,
   })
   ```
3. If `indent` folding isn’t sufficient, switch to `marker` folding and add markers to your Zsh scripts for important sections.

### Summary
- There’s no default Treesitter parser for Zsh in `nvim-treesitter`, but the `bash` parser can be used as a substitute for syntax highlighting and limited folding.
- For folding, use Neovim’s built-in methods like `indent`, `marker`, or `syntax` for Zsh files since Treesitter support is incomplete.
- Alternative plugins like `vim-polyglot` can enhance Zsh syntax highlighting if needed.
- Check the Tree-sitter community for third-party Zsh parsers, though they may not be widely available or maintained yet.

If you’d like help setting up a specific folding method or plugin for Zsh, or if you find a third-party parser to integrate, let me know, and I’ll assist further!

# === USER ===

something is still wrong. i can see all folds and control them with markdown and lua. however, folding doesn't work with typescript. actually, something weird happened. it briefly worked with only one function in typescript. but now, when i try to fold/unfold that function, it says "no folds found". and it says this for every function. somehow, the folds are not being detected. do you see an issue with this config?

```lua
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    dependencies = { "nvim-treesitter/nvim-treesitter", "LhKipp/nvim-nu" },
    run = ":TSUpdate",
    config = function()
      ---@diagnostic disable-next-line: missing-fields
      require("nvim-treesitter.configs").setup({
        -- Install parsers for various languages
        ensure_installed = {
          "css",
          "html",
          "javascript",
          "jsdoc",
          "json",
          "jsonc",
          "lua",
          "markdown",
          "markdown_inline",
          "nu",
          "python",
          "rust",
          "toml",
          "tsx",
          "typescript",
          "wgsl",
          "yaml",
          -- "zsh",
          "bash",
        }, -- Add more languages as needed

        -- Enable Treesitter-based syntax highlighting
        highlight = {
          enable = true, -- Enable Treesitter highlighting
          additional_vim_regex_highlighting = false, -- Disable Vim's regex-based highlighting
        },

        -- You can enable more Treesitter features as needed (optional)
        indent = { enable = false }, -- Enable Treesitter-based indentation (optional)

        -- Folding
        fold = { enable = true }, -- Enable Treesitter-based folding (optional)

        -- Required for nvim-treesitter-textobjects
        textobjects = {
          select = {
            enable = true,
            lookahead = true, -- Automatically jump forward to textobj if cursor is outside
            keymaps = {
              -- Define a custom text object for markdown fenced code blocks
              ["ic"] = {
                query = "@codeblock.inner",
                desc = "Select inside markdown code block",
              },
              ["ac"] = {
                query = "@codeblock.outer",
                desc = "Select around markdown code block",
              },
              ["if"] = {
                query = "@function.inner",
                desc = "Select inside function (TypeScript, etc.)",
              },
              ["af"] = {
                query = "@function.outer",
                desc = "Select around function (TypeScript, etc.)",
              },
              ["ik"] = {
                query = "@class.inner",
                desc = "Select inside class (TypeScript, etc.)",
              },
              ["ak"] = {
                query = "@class.outer",
                desc = "Select around class (TypeScript, etc.)",
              },
            },
            -- Optionally, configure selection modes or other settings
            selection_modes = {
              ["@codeblock.inner"] = "V", -- Use linewise visual mode for inner selection
              ["@codeblock.outer"] = "V", -- Use linewise visual mode for outer selection
              ["@function.inner"] = "V",
              ["@function.outer"] = "V",
              ["@class.inner"] = "V",
              ["@class.outer"] = "V",
            },
          },
          move = {
            enable = true,
            set_jumps = true, -- Add to jump list for navigation history
            goto_next_start = {
              ["]c"] = {
                query = "@codeblock.outer",
                desc = "Next code block start",
              },
              ["]f"] = {
                query = "@function.outer",
                desc = "Next function start",
              },
              ["]k"] = { query = "@class.outer", desc = "Next class start" },
            },
            goto_next_end = {
              ["]C"] = {
                query = "@codeblock.outer",
                desc = "Next code block end",
              },
            },
            goto_previous_start = {
              ["[c"] = {
                query = "@codeblock.outer",
                desc = "Previous code block start",
              },
              ["[f"] = {
                query = "@function.outer",
                desc = "Previous function start",
              },
              ["[k"] = { query = "@class.outer", desc = "Previous class start" },
            },
            goto_previous_end = {
              ["[C"] = {
                query = "@codeblock.outer",
                desc = "Previous code block end",
              },
            },
          },
        },
      })

      -- Define the custom Tree-sitter queries for markdown code blocks
      vim.treesitter.query.set(
        "markdown",
        "textobjects",
        [[
      (fenced_code_block
        (code_fence_content) @codeblock.inner
      ) @codeblock.outer
    ]]
      )

      -- Enable Treesitter folding globally
      vim.opt.foldmethod = "expr"
      vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
      vim.opt.foldenable = true
      vim.opt.foldlevelstart = 99 -- Start with all folds open
    end,
  },
```

# === ASSISTANT ===

Thanks for sharing your updated configuration and the detailed description of the issue with TypeScript folding. I’m glad to see that folding works for Markdown and Lua, but the fact that it’s not working for TypeScript (and briefly worked for one function before failing with "no folds found") suggests a specific issue with how Treesitter folding is being applied to TypeScript files. Let's analyze your config, diagnose the problem, and propose solutions.

### Analysis of Your Config
1. **Treesitter Setup**:
   - You have `nvim-treesitter` and `nvim-treesitter-textobjects` properly set up with `ensure_installed` including `typescript` and `tsx`, so the necessary parsers are installed.
   - Syntax highlighting (`highlight = { enable = true }`) and textobjects for TypeScript (e.g., `if` for `@function.inner`, `af` for `@function.outer`) are configured, indicating that Treesitter is parsing TypeScript files correctly for other features.
   - Folding is enabled in Treesitter with `fold = { enable = true }`, which is correct for activating Treesitter’s folding module.

2. **Global Folding Settings**:
   - You’ve set `vim.opt.foldmethod = "expr"`, `vim.opt.foldexpr = "nvim_treesitter#foldexpr()"`, `vim.opt.foldenable = true`, and `vim.opt.foldlevelstart = 99` globally in your config. These settings should enable Treesitter-based folding for all supported filetypes, including TypeScript, with all folds starting open (due to the high `foldlevelstart` value).
   - These settings look correct and should work for TypeScript, as they do for Lua and Markdown.

3. **No Filetype-Specific Overrides**:
   - There are no autocommands or overrides in your config that disable folding for TypeScript or treat it differently from Lua or Markdown. This rules out a configuration conflict specific to filetypes within the provided snippet.

### Why Folding Isn’t Working for TypeScript
Given that folding works for Lua and Markdown but not for TypeScript (with the odd behavior of briefly working for one function), the issue is likely not with your configuration but with one of the following:

1. **Treesitter Parser Issue for TypeScript**:
   - Even though the `typescript` and `tsx` parsers are installed, there could be a problem with the parser’s folding logic. Treesitter folding relies on the parser defining foldable regions (like functions, classes, or blocks) via queries or built-in rules. If the TypeScript parser or its folding queries are outdated, incomplete, or buggy, folding might fail or behave inconsistently.
   - The brief moment when one function folded could indicate a temporary parse success that was lost due to a buffer refresh, syntax error, or parser update.

2. **Buffer or Syntax Parsing Error**:
   - If your TypeScript file contains syntax errors or complex constructs (e.g., JSX in TSX, decorators, or incomplete code), the Treesitter parser might fail to build a complete syntax tree, resulting in no foldable regions being detected. This can lead to "no folds found" errors when trying to fold/unfold.
   - The brief folding success might have occurred before a syntax error was introduced or before the buffer was re-parsed.

3. **Treesitter Module or Neovim Version**:
   - If you’re using an older version of Neovim (pre-0.9 or 0.10) or an outdated `nvim-treesitter` plugin, there could be compatibility issues with the TypeScript parser or folding module. Neovim 0.9+ and recent `nvim-treesitter` updates have improved folding support, but bugs or inconsistencies might persist in specific setups.
   - The `foldexpr` function (`nvim_treesitter#foldexpr()`) might not be correctly evaluating folds for TypeScript due to a bug or misconfiguration.

4. **Conflicting Plugins or Settings**:
   - Another plugin or a setting outside the provided config snippet (e.g., in another part of your `init.lua` or a filetype plugin) might be interfering with folding for TypeScript. For example, a plugin might reset `foldmethod` or `foldexpr` for TypeScript files, or there could be a conflicting autocommand.

### Why "No Folds Found" Error?
The "no folds found" message appears when you attempt to fold or unfold (e.g., with `zc` or `zo`) but Neovim cannot identify any foldable regions at the cursor position or in the buffer. Since `foldmethod=expr` and `foldexpr=nvim_treesitter#foldexpr()` are set, this means the Treesitter parser isn’t providing any fold information for the TypeScript file, likely due to one of the reasons above (parser issue, syntax error, or buffer state).

### Debugging Steps
Let’s systematically debug the issue to pinpoint why folding isn’t working for TypeScript. Follow these steps and note the results:

1. **Check Folding Settings in a TypeScript File**:
   Open a TypeScript file and run the following commands to confirm the folding configuration:
   ```
   :set foldmethod?
   :set foldexpr?
   :set foldenable?
   :verbose set foldmethod?
   ```
   - Expected output should be `foldmethod=expr`, `foldexpr=nvim_treesitter#foldexpr()`, and `foldenable=true`. If these differ (e.g., `foldmethod=manual`), something is overriding your global settings for TypeScript.
   - The `:verbose` output will show where the setting was last changed (e.g., a plugin or autocommand).

2. **Check Treesitter Parser Status**:
   Run the following to ensure the TypeScript parser is active for the current buffer:
   ```
   :TSModuleInfo
   ```
   Look for `typescript` or `tsx` under the "enabled" modules for highlighting or folding. If it’s not listed or shows as disabled, there’s an issue with the parser installation or activation.
   Also, check if Treesitter is parsing the buffer:
   ```
   :echo nvim_treesitter#statusline()
   ```
   This should show the current node type under the cursor if parsing is active.

3. **Check for Syntax Errors or Parser Issues**:
   Inspect the TypeScript file for syntax errors or complex code that might break parsing. Temporarily simplify the file (e.g., reduce it to a single function like `function test() { return 1; }`) and see if folding works:
   ```
   zc  " Try to close a fold
   zo  " Try to open a fold
   zR  " Open all folds in the file
   ```
   If folding works on a simple file but not on your original file, the issue is likely with the file’s content breaking the parser.

4. **Update Treesitter and Parsers**:
   Ensure `nvim-treesitter` and the TypeScript parser are up to date, as bugs in older versions might cause folding issues:
   ```
   :TSUpdate
   :TSUpdate typescript
   :TSUpdate tsx
   ```
   After updating, restart Neovim and test folding again.

5. **Check Neovim Version**:
   Run `:version` to confirm you’re on a recent Neovim version (0.9 or 0.10 recommended). If not, consider updating, as folding support with Treesitter has improved in recent releases.

6. **Test Without Other Plugins**:
   Temporarily disable other plugins (especially those related to TypeScript, like LSPs or syntax plugins) to rule out interference. Start Neovim with a minimal config:
   ```
   nvim --clean -u NONE
   ```
   Then manually load only `nvim-treesitter` and test folding on a TypeScript file after setting the folding options manually:
   ```
   :lua vim.opt.foldmethod = "expr"
   :lua vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
   :lua vim.opt.foldenable = true
   ```

### Proposed Fixes
Based on the likely causes, here are immediate changes and workarounds to try. Add or modify these in your `init.lua` within the `config` function of `nvim-treesitter-textobjects` or as separate autocommands.

#### 1. Force Re-Parsing for TypeScript
Sometimes, the Treesitter parser doesn’t update the fold information after buffer changes. Force a re-parse by adding an autocommand to refresh folding for TypeScript files on buffer events:
```lua
vim.api.nvim_create_autocmd({"BufEnter", "TextChanged", "InsertLeave"}, {
  pattern = {"*.ts", "*.tsx"},
  callback = function()
    vim.treesitter.start() -- Restart Treesitter parsing for the buffer
    vim.cmd("normal! zx") -- Update folds (zx recalculates folds)
  end,
})
```

#### 2. Fallback to Syntax or Indent Folding for TypeScript
If Treesitter folding fails, temporarily fall back to Neovim’s built-in `syntax` or `indent` folding for TypeScript as a workaround:
```lua
vim.api.nvim_create_autocmd("FileType", {
  pattern = {"typescript", "typescriptreact"},
  callback = function()
    -- Fallback if Treesitter folding doesn't work
    if vim.fn.foldmethod() == "expr" and vim.fn.foldlevel(1) == 0 then
      vim.opt_local.foldmethod = "indent" -- or "syntax" if supported
    end
  end,
})
```
This checks if no folds are detected with `expr` and switches to `indent`. You can toggle back to `expr` manually if needed.

#### 3. Check and Re-Install TypeScript Parser
If the parser might be corrupted or outdated, reinstall it:
```
:TSUninstall typescript tsx
:TSInstall typescript tsx
```
Restart Neovim after reinstalling.

#### 4. Add Debugging Output
Add a temporary debug to see if Treesitter folding is being calculated for TypeScript. Add this to your config:
```lua
vim.api.nvim_create_autocmd("FileType", {
  pattern = {"typescript", "typescriptreact", "lua", "markdown"},
  callback = function()
    print("Filetype: " .. vim.bo.filetype)
    print("Foldmethod: " .. vim.opt_local.foldmethod:get)
    print("Foldexpr: " .. vim.opt_local.foldexpr:get)
    print("Foldenable: " .. tostring(vim.opt_local.foldenable:get))
  end,
})
```
This will print the folding settings when opening a file of these types. Compare the output for Lua/Markdown (where folding works) vs. TypeScript (where it doesn’t).

### Updated Config Snippet
Here’s your config with the above fixes integrated. Replace the relevant part of your `config` function with this:
```lua
config = function()
  ---@diagnostic disable-next-line: missing-fields
  require("nvim-treesitter.configs").setup({
    ensure_installed = {
      "css", "html", "javascript", "jsdoc", "json", "jsonc", "lua",
      "markdown", "markdown_inline", "nu", "python", "rust", "toml",
      "tsx", "typescript", "wgsl", "yaml", "bash",
    },
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = false,
    },
    indent = { enable = false },
    fold = { enable = true },
    textobjects = {
      select = {
        enable = true,
        lookahead = true,
        keymaps = {
          ["ic"] = { query = "@codeblock.inner", desc = "Select inside markdown code block" },
          ["ac"] = { query = "@codeblock.outer", desc = "Select around markdown code block" },
          ["if"] = { query = "@function.inner", desc = "Select inside function" },
          ["af"] = { query = "@function.outer", desc = "Select around function" },
          ["ik"] = { query = "@class.inner", desc = "Select inside class" },
          ["ak"] = { query = "@class.outer", desc = "Select around class" },
        },
        selection_modes = {
          ["@codeblock.inner"] = "V", ["@codeblock.outer"] = "V",
          ["@function.inner"] = "V", ["@function.outer"] = "V",
          ["@class.inner"] = "V", ["@class.outer"] = "V",
        },
      },
      move = {
        enable = true,
        set_jumps = true,
        goto_next_start = {
          ["]c"] = { query = "@codeblock.outer", desc = "Next code block start" },
          ["]f"] = { query = "@function.outer", desc = "Next function start" },
          ["]k"] = { query = "@class.outer", desc = "Next class start" },
        },
        goto_next_end = {
          ["]C"] = { query = "@codeblock.outer", desc = "Next code block end" },
        },
        goto_previous_start = {
          ["[c"] = { query = "@codeblock.outer", desc = "Previous code block start" },
          ["[f"] = { query = "@function.outer", desc = "Previous function start" },
          ["[k"] = { query = "@class.outer", desc = "Previous class start" },
        },
        goto_previous_end = {
          ["[C"] = { query = "@codeblock.outer", desc = "Previous code block end" },
        },
      },
    },
  })

  vim.treesitter.query.set(
    "markdown",
    "textobjects",
    [[
    (fenced_code_block
      (code_fence_content) @codeblock.inner
    ) @codeblock.outer
    ]]
  )

  -- Enable Treesitter folding globally
  vim.opt.foldmethod = "expr"
  vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
  vim.opt.foldenable = true
  vim.opt.foldlevelstart = 99

  -- Force re-parsing for TypeScript on buffer events
  vim.api.nvim_create_autocmd({"BufEnter", "TextChanged", "InsertLeave"}, {
    pattern = {"*.ts", "*.tsx"},
    callback = function()
      vim.treesitter.start() -- Restart Treesitter parsing
      vim.cmd("normal! zx") -- Recalculate folds
    end,
  })

  -- Debug folding settings for different filetypes
  vim.api.nvim_create_autocmd("FileType", {
    pattern = {"typescript", "typescriptreact", "lua", "markdown"},
    callback = function()
      print("Filetype: " .. vim.bo.filetype)
      print("Foldmethod: " .. vim.opt_local.foldmethod:get)
      print("Foldexpr: " .. vim.opt_local.foldexpr:get)
      print("Foldenable: " .. tostring(vim.opt_local.foldenable:get))
    end,
  })
end,
```

### Additional Notes
- **Brief Folding Success**: The fact that one function briefly folded suggests the parser can work under certain conditions. This points to a syntax error, buffer state, or parser refresh issue. Simplifying the file or forcing a re-parse (as in the autocommand above) might help.
- **LSP or Other Plugins**: If you’re using a TypeScript LSP (like `tsserver`), it might provide folding ranges that conflict with Treesitter. Check if disabling LSP folding (if enabled) helps:
  ```
  :lua vim.lsp.buf.execute_command({command = "_typescript.setFoldingRanges", arguments = {false}})
  ```
  Or disable LSP temporarily to test.

### Summary
- Your config looks correct for enabling Treesitter folding globally, including for TypeScript.
- The issue likely stems from a Treesitter parser problem, syntax error in the file, buffer parsing state, or a conflicting plugin/setting.
- Follow the debugging steps to confirm settings and parser status, update `nvim-treesitter`, and test with a simple TypeScript file.
- Use the updated config with forced re-parsing and debugging output to identify discrepancies.

After running the debugging commands or applying the updated config, let me know the results (e.g., output of `:set foldmethod?` or debug prints for TypeScript vs. Lua). If folding still doesn’t work, I can help narrow it down further or explore additional workarounds!

# === USER ===

my markdown syntax highlighting supports bash. however, it does not seem to support zsh. however, zsh highlights correctly if i change the zsh code blocks into bash code blocks. is there any way to add zsh syntax highlighting to markdown code blocks? maybe i can just somehow tell it to regard zsh as bash?

# === ASSISTANT ===

I'm glad to help with getting Zsh syntax highlighting working in Markdown code blocks. The behavior you're describing—Markdown syntax highlighting supporting Bash but not Zsh in code blocks, while Zsh highlights correctly when labeled as Bash—makes sense given how Markdown and Treesitter handle code block languages in Neovim. Let's analyze the issue and provide a solution to add Zsh syntax highlighting to Markdown code blocks by mapping Zsh to use the Bash parser or configuring Treesitter to recognize it.

### Why Zsh Isn't Highlighted in Markdown Code Blocks
1. **Markdown Code Blocks and Language Detection**:
   - In Markdown files, code blocks often specify a language identifier (e.g., ````bash or ````zsh) to indicate the language for syntax highlighting.
   - The `nvim-treesitter` plugin, which handles syntax highlighting for Markdown and embedded code blocks, relies on Treesitter parsers for the specified language. When a code block is labeled with a language (like `bash`), Treesitter uses the corresponding parser (if installed) to highlight the content.
   - As discussed earlier, there is no dedicated Treesitter parser for Zsh in the default `nvim-treesitter` setup. When a code block is labeled as `zsh`, Treesitter doesn't have a parser to match it, so it falls back to no highlighting or plain text.

2. **Why Bash Works and Zsh Doesn't**:
   - Since you have the `bash` parser installed (as seen in your `ensure_installed` list), code blocks labeled as `bash` are highlighted correctly using the Bash parser.
   - When you change a Zsh code block to `bash`, Treesitter applies the Bash parser, and because Zsh syntax is largely compatible with Bash, the highlighting works reasonably well.

3. **Neovim's Filetype Detection Outside Markdown**:
   - Outside Markdown (e.g., in standalone `.zsh` files), Neovim might still highlight Zsh content using either a built-in syntax file (`zsh.vim` or `sh.vim`) or by mapping Zsh to the Bash parser in Treesitter. This explains why standalone Zsh files might highlight correctly, but Markdown code blocks labeled `zsh` do not.

### Solution: Map Zsh to Bash for Markdown Code Blocks
Since there’s no dedicated Zsh parser in Treesitter, the simplest and most effective solution is to tell `nvim-treesitter` to treat code blocks labeled as `zsh` as if they were `bash`. Treesitter supports language aliases or custom mappings for embedded code blocks in Markdown via its configuration or query overrides. Alternatively, you can adjust Neovim’s behavior to map Zsh to Bash globally or for Markdown files.

Here are a few approaches to achieve Zsh syntax highlighting in Markdown code blocks:

#### 1. Configure Treesitter to Alias Zsh to Bash in Markdown
Treesitter allows you to override the language used for code blocks in Markdown by customizing the language detection. You can map `zsh` to `bash` for embedded code blocks by extending the Markdown parser’s behavior.

Add the following to your `init.lua` within or after the `nvim-treesitter.configs.setup` call to alias `zsh` to `bash` in Markdown code blocks:

```lua
-- After or within your nvim-treesitter setup
require("nvim-treesitter.configs").setup({
  ensure_installed = {
    "bash", "lua", "markdown", "markdown_inline", -- other languages...
  },
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  fold = { enable = true },
  -- other settings...
})

-- Alias zsh to bash for Markdown code blocks
vim.treesitter.language.register("bash", "zsh")
```

- `vim.treesitter.language.register("bash", "zsh")` tells Treesitter to use the `bash` parser whenever it encounters a language identifier of `zsh`. This works globally, so it will apply to Markdown code blocks labeled as ````zsh as well as standalone Zsh files.
- After adding this, restart Neovim or reload your config (e.g., with `:source ~/.config/nvim/init.lua`) and test a Markdown file with a Zsh code block. It should now highlight using the Bash parser.

#### 2. Custom Markdown Query for Language Detection (Advanced)
If the above global alias doesn’t work or you want to limit the aliasing to Markdown files, you can customize the Treesitter queries for Markdown to map `zsh` to `bash` specifically in code blocks. This requires overriding the language detection logic for Markdown’s `fenced_code_block`.

Add a custom query or configuration for Markdown to map Zsh to Bash. Place this in your `init.lua` or in a separate file under `~/.config/nvim/after/queries/markdown/highlights.scm` if you prefer:

```lua
-- Custom handling for Markdown code blocks to map zsh to bash
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    -- Override language detection for zsh in Markdown code blocks
    local ts_language = require("vim.treesitter.language")
    local original_get_lang = ts_language.get_lang
    ts_language.get_lang = function(lang)
      if lang == "zsh" then
        return "bash"
      end
      return original_get_lang(lang)
    end
  end,
})
```

This approach intercepts the language detection for Markdown files and maps `zsh` to `bash` only in that context. It’s more targeted than the global alias but achieves the same result. Restart Neovim or reload the config after adding this.

#### 3. Change Code Block Labels Manually or via Autocommand
If you don’t want to modify Treesitter’s behavior, a simpler (but less automated) approach is to label all Zsh code blocks as `bash` in your Markdown files. Since you’ve noticed that works, you can either:
- Manually edit ````zsh to ````bash in your Markdown files.
- Use a Neovim autocommand or keymap to replace `zsh` with `bash` in code block headers when saving or editing Markdown files. For example:
  ```lua
  vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*.md",
    callback = function()
      vim.cmd([[%s/```zsh/```bash/g]])
    end,
  })
  ```
  This automatically replaces ````zsh with ````bash when saving a Markdown file. It’s a quick hack but not ideal for long-term use since it modifies your file content.

#### 4. Use Non-Treesitter Syntax Highlighting for Zsh in Markdown
If Treesitter aliasing doesn’t work or you prefer not to rely on Treesitter for Zsh, you can fall back to Neovim’s built-in syntax highlighting or a third-party plugin for shell scripts. Neovim’s default syntax files or plugins like `vim-polyglot` can highlight Zsh content in Markdown code blocks if configured properly.

- Install `vim-polyglot` (if not already installed) for better shell script support:
  ```lua
  { "sheerun/vim-polyglot" }
  ```
- Enable legacy Vim syntax highlighting for Markdown code blocks alongside Treesitter (if Treesitter doesn’t handle Zsh well):
  ```lua
  require("nvim-treesitter.configs").setup({
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = true, -- Enable legacy Vim highlighting as fallback
    },
    -- other settings...
  })
  ```
  This allows Neovim’s built-in syntax files (e.g., `sh.vim` or `zsh.vim`, if available) to handle highlighting for Zsh code blocks when Treesitter doesn’t have a parser. Note that this might lead to inconsistent highlighting compared to Treesitter’s output.

#### 5. Check for Community Zsh Support or Custom Parsers
As mentioned in previous responses, there might be third-party Treesitter parsers for Zsh in the community. While not part of the default `nvim-treesitter` setup, you can search GitHub for `tree-sitter-zsh` or check the Tree-sitter organization for updates. If found, you can integrate it as a custom parser:
```lua
local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
parser_config.zsh = {
  install_info = {
    url = "https://github.com/user/tree-sitter-zsh", -- Replace with actual repo if found
    files = {"src/parser.c"},
    branch = "main",
  },
  filetype = "zsh",
}
```
Then add `zsh` to `ensure_installed` and install it with `:TSInstall zsh`. This is speculative since a widely maintained Zsh parser isn’t currently available, but it’s worth checking for updates.

### Recommended Solution
The simplest and most reliable approach is **Option 1: Alias Zsh to Bash Globally**. Add the following to your `init.lua` after your `nvim-treesitter` setup:
```lua
-- Alias zsh to bash for syntax highlighting in code blocks and files
vim.treesitter.language.register("bash", "zsh")
```
This ensures that any code block labeled as ````zsh in Markdown files (or standalone `.zsh` files) will use the `bash` parser for highlighting. Since Zsh and Bash syntax are similar, this should provide reasonable highlighting for most Zsh code.

If you want to confirm this works, create a test Markdown file with both Bash and Zsh code blocks:
```markdown
# Test Code Blocks

## Bash Code Block
```bash
for i in {1..3}; do
  echo "Number: $i"
done
```

## Zsh Code Block
```zsh
for i in {1..3}; do
  echo "Number: $i"
done
```

After adding the alias and reloading your config, both code blocks should have similar syntax highlighting.

### Additional Debugging
If the alias doesn’t work as expected:
1. Confirm the Bash parser is installed and active:
   ```
   :TSModuleInfo
   ```
   Check if `bash` is listed as enabled for highlighting.
2. Check the language detection in a Markdown file with a Zsh code block. Place your cursor inside the Zsh code block and run:
   ```
   :echo nvim_treesitter#statusline()
   ```
   This should show the node type and ideally indicate `bash` as the language if the alias worked.
3. If it still doesn’t highlight, ensure your `nvim-treesitter` plugin is up to date:
   ```
   :TSUpdate
   ```

### Summary
- Markdown code blocks labeled as `zsh` don’t highlight because there’s no default Treesitter parser for Zsh.
- You can alias `zsh` to `bash` using `vim.treesitter.language.register("bash", "zsh")` to apply Bash highlighting to Zsh code blocks.
- Alternatively, manually label Zsh blocks as `bash`, use legacy Vim syntax highlighting, or search for a custom Zsh parser.
- The alias method is the most straightforward and should work with your existing setup.

If you apply the alias and still face issues, or if the highlighting isn’t satisfactory for Zsh-specific syntax, let me know, and I can help refine the solution or explore other plugins like `vim-polyglot` in more detail!

# === USER ===



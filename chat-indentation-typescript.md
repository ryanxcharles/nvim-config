i'm having a weird problem with my neovim set up. i use lazyvim. i'm editing a
typescript file. when i have a function inside an object, the indentation is
off. when i add a new line after the current line, is it not indented properly.
it will be missing one or two levels of indentation.

take this code for example:

```typescript
import { z } from "zod";
import type { IncomingHttpHeaders } from "node:http";
import {
  storeFile,
  getFileById,
  getUserFiles,
  deleteFile as deleteFileById,
} from "~src/db/models/data";
import { encrypt, decrypt } from "~src/encryption";
import { base } from "../base";

//derives the user id from the headers

export const routeData = {
  uploadFile: base
    .input(
      z.object({
        base64File: z.string(),
        fileName: z.string().optional(),
        mimeType: z.string().optional(),
      }),
    )
    .handler(async ({ input, context }) => {
      const userId = context.user?.id as number;

      const fileName = input.fileName ?? "upload";
      const mimeType = input.mimeType ?? "application/octet-stream";

      const file = await storeFile(
        input.base64File,
        fileName,
        mimeType,
        userId,
      );

      return {
        id: file.id,
        filename: file.filename,
        mimeType: file.mimeType,
        fileSize: file.fileSize,
        createdAt: file.createdAt,
      };
    }),

  getFile: base
    .input(z.object({ fileId: z.string() }))
    .handler(async ({ input, context }) => {
      const userId = context.user?.id as number;

      const file = await getFileById(input.fileId);
      if (!file) throw new Error("File not found");
      if (file.uploadedBy !== userId) throw new Error("Access denied");

      const decryptedData = decrypt(file.encryptedData);
      const base64Data = Buffer.from(decryptedData).toString("base64");

      return {
        id: file.id,
        filename: file.filename,
        mimeType: file.mimeType,
        fileSize: file.fileSize,
        createdAt: file.createdAt,
        dataBase64: base64Data,
      };
    }),

  listUserFiles: base.handler(async ({ context }) => {
    const userId = context.user?.id as number;

    const files = await getUserFiles(userId);
    return files.map((f) => ({
      id: f.id,
      filename: f.filename,
      mimeType: f.mimeType,
      fileSize: f.fileSize,
      createdAt: f.createdAt,
    }));
  }),

  deleteFile: base
    .input(z.object({ fileId: z.string() }))
    .handler(async ({ input, context }) => {
      const userId = context.user?.id as number;

      const file = await getFileById(input.fileId);
      if (!file) throw new Error("File not found");
      if (file.uploadedBy !== userId) throw new Error("Access denied");

      const ok = await deleteFileById(input.fileId);
      return { success: ok };
    }),
};
```

any time i add new code to those routes, my editor will "un-indent" the new
line. it's annoying. any idea what might be causing this? probably one of my
neovim plugins, hopefully something fixable?

# === ASSISTANT ===

This is a common issue in LazyVim/Neovim with TypeScript files, and it's likely
related to one of these indentation-related plugins or settings. Here are the
most probable causes and solutions:

## Most Likely Culprit: Tree-sitter Indentation

The issue is probably with Tree-sitter's TypeScript indentation rules not
handling method chaining in objects correctly.

**Solution 1: Adjust Tree-sitter indentation**

Add this to your `~/.config/nvim/lua/config/options.lua`:

```lua
-- Disable tree-sitter indentation for TypeScript
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "typescript", "typescriptreact" },
  callback = function()
    vim.opt_local.indentexpr = ""
  end,
})
```

Or try this more targeted approach in the same file:

```lua
-- Use cindent for TypeScript instead of tree-sitter
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "typescript", "typescriptreact" },
  callback = function()
    vim.opt_local.cindent = true
    vim.opt_local.indentexpr = ""
  end,
})
```

## Solution 2: Configure nvim-treesitter

If you want to keep Tree-sitter but fix the indentation, add this to your
Tree-sitter config (usually in `~/.config/nvim/lua/plugins/treesitter.lua` or
wherever you configure it):

```lua
return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    indent = {
      enable = true,
      -- Disable for problematic languages
      disable = { "typescript", "typescriptreact" },
    },
  },
}
```

## Solution 3: LSP/Formatter Configuration

If you're using TypeScript LSP with formatting, you might want to adjust the
formatting options. Add this to your LSP config:

```lua
-- In your LSP configuration
require('lspconfig').tsserver.setup({
  settings = {
    typescript = {
      indentStyle = "Smart",
      indentSize = 2,
    },
    javascript = {
      indentStyle = "Smart", 
      indentSize = 2,
    }
  }
})
```

## Solution 4: Check for Conflicting Plugins

LazyVim might have conflicting indentation plugins. Check if you have any of
these and consider disabling them for TypeScript:

```lua
-- Add to your plugin configuration to disable specific features
{
  "nvim-treesitter/nvim-treesitter",
  opts = {
    indent = { enable = false }, -- Disable tree-sitter indenting entirely
  },
}
```

## Quick Debug Steps

1. **Check what's handling indentation:**
   ```vim
   :set indentexpr?
   :set cindent?
   :set smartindent?
   ```

2. **Test with minimal config:** Temporarily disable Tree-sitter indentation and
   see if the problem persists.

3. **Check LazyVim extras:** Make sure you don't have conflicting TypeScript
   extras enabled.

The **first solution** (disabling Tree-sitter indentation for TypeScript) is
usually the quickest fix for this specific issue with method chaining in object
literals. The Tree-sitter TypeScript parser sometimes gets confused with the
complex nesting in your code pattern.

Try Solution 1 first, and let me know if that resolves the indentation issue!

# === USER ===

the option i chose is to disable treesitter indentation for typescript and
typescriptreact files. that worked. however, i wonder, is there some way to fix
treesitter? how can such a popular tool be broken for something so important?

# === ASSISTANT ===

You're absolutely right to be frustrated! This is indeed a surprisingly common
issue with such a fundamental feature. Here's what's happening and what you can
do about it:

## Why Tree-sitter Indentation is "Broken"

Tree-sitter indentation isn't technically broken—it's **incomplete**. Here's
why:

1. **Complex Language Patterns**: Your code has method chaining in object
   literals with arrow functions and generics. Tree-sitter's indentation queries
   need explicit rules for every syntactic pattern.

2. **Community-Maintained**: Tree-sitter indentation rules are maintained by the
   community, not the core Tree-sitter team. TypeScript is particularly complex.

3. **Query-Based System**: Unlike traditional indenters that use heuristics,
   Tree-sitter uses explicit queries. If a pattern isn't covered, it fails.

## How to Actually Fix Tree-sitter

If you want to contribute to fixing this (and help thousands of other
developers), here's how:

### 1. Find the TypeScript Indentation Queries

```bash
# Find where your Tree-sitter queries are stored
:echo stdpath('data') . '/lazy/nvim-treesitter/queries/typescript/indents.scm'
```

### 2. Debug the Issue

Add this to your config to see what Tree-sitter is doing:

```lua
-- Debug tree-sitter indentation
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "typescript" },
  callback = function()
    -- This will show you the syntax tree
    vim.keymap.set("n", "<leader>ti", "<cmd>InspectTree<cr>", { buffer = true })
    -- This will show indentation debugging
    vim.keymap.set("n", "<leader>td", function()
      local row = vim.api.nvim_win_get_cursor(0)[1]
      print("Indent for line " .. row .. ": " .. vim.fn.indent(row))
    end, { buffer = true })
  end,
})
```

### 3. The Actual Fix Location

The issue is likely in the Tree-sitter TypeScript grammar's indentation queries.
You can:

**Option A: Local Fix**

```bash
# Copy the queries locally to modify them
mkdir -p ~/.config/nvim/queries/typescript/
cp "$(nvim --headless -c 'echo stdpath("data")' -c 'qa' 2>&1)/lazy/nvim-treesitter/queries/typescript/indents.scm" ~/.config/nvim/queries/typescript/
```

Then edit `~/.config/nvim/queries/typescript/indents.scm` to add rules for
method chaining in objects.

**Option B: Contribute Upstream** The real fix should go to:
https://github.com/tree-sitter/tree-sitter-typescript

### 4. What the Fix Might Look Like

The indentation query probably needs something like:

```scheme
; Method chaining in object literals
(object
  (pair
    value: (call_expression
      function: (member_expression) @indent.begin))) @indent.end

; Function expressions in object methods  
(object
  (pair
    value: (arrow_function) @indent.begin)) @indent.end
```

## Why This Happens to Popular Tools

This is actually a common pattern in open-source:

1. **Core vs. Periphery**: Tree-sitter core is rock-solid, but language-specific
   features like indentation are "periphery"
2. **Maintainer Bandwidth**: The Tree-sitter team focuses on the parser, not
   every language's edge cases
3. **TypeScript Complexity**: TypeScript is one of the most syntactically
   complex languages Tree-sitter supports

## Better Alternatives

If you want Tree-sitter parsing but better indentation:

```lua
-- Use tree-sitter for syntax highlighting, but vim's built-in for indentation
{
  "nvim-treesitter/nvim-treesitter",
  opts = {
    highlight = { enable = true },
    indent = { 
      enable = true,
      disable = { "typescript", "typescriptreact", "javascript", "javascriptreact" }
    },
  },
}

-- Then use vim's built-in TypeScript indentation
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "typescript", "typescriptreact" },
  callback = function()
    vim.opt_local.cindent = true
    vim.opt_local.cinoptions = "j1,(0,ws,Ws,g0"
  end,
})
```

The frustrating truth is that for complex languages like TypeScript, traditional
indentation engines (like VSCode's) often work better than Tree-sitter's
query-based approach. Your solution to disable it was the right call!

# === USER ===

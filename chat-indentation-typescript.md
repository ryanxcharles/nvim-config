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

# Neovim

Config: `~/.config/nvim/`. Leader is Space (which-key shows what follows), local leader is `,`.

## Layout

| Path | Holds |
|---|---|
| `init.lua` | bootstraps lazy.nvim, sets the leaders, loads `core` and every file in `lua/plugins/` |
| `lua/core/options.lua` | editor options (`clipboard=unnamedplus`: yanks go to the macOS clipboard) |
| `lua/core/keymaps.lua` | keys that don't belong to a plugin |
| `lua/plugins/*.lua` | one plugin (or a small group) per file, lazy.nvim spec |
| `lua/plugins/lsp/` | `init.lua` plus one file per language: bash, c, cmake, js, lua, markup, powershell, python, rust, web |
| `lua/snippets/` | own LuaSnip snippets |
| `ftplugin/` | per-filetype settings: html, javascript, json, lua, markdown, norg, python, sh |
| `templates/` | file templates |
| `lazy-lock.json` | pinned plugin versions; not tracked (in `.gitignore`), so each machine keeps its own |
| `TODO.md` | open nvim work |

## Working with it

- Edit: `nvn` from the shell. lazy.nvim notices changed plugin files by itself.
- Plugins: `:Lazy` (update, clean, profile).
- LSP servers and tools: `:Mason`. Health: `:checkhealth`.
- Files from the launcher or Finder `e` open through `~/.local/bin/edit` in a running nvim (see `launcher.md`).
- Panes: Ctrl+h/j/k/l move between nvim splits and tmux panes (vim-tmux-navigator).
- PDFs open in zathura (`zathura/zathurarc`).

The `raspbian` branch carries a stripped-down copy of this config for the Pi.

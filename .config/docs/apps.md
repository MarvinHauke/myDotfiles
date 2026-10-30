# Other apps (VS Code, zathura, plain vim)

Configs that need little explanation. Keys are listed in `keys.md` (zathura); VS Code keeps its own keys.

## VS Code

Config: `~/.config/Code/User/settings.json`, `keybindings.json` (the folder VS Code uses with `XDG_CONFIG_HOME`).

- Vim extension with neovim backend (`vim.enableNeovim`), leader Space, easymotion and sneak on.
- `keybindings.json` maps Caps Lock to the vim extension's Escape. Karabiner already turns tapped Caps into Esc,
  so this only matters without Karabiner.
- Ctrl+j / Ctrl+k move through suggestions, lists and quick open, like in fzf and nvim.
- Space f / Space d in the explorer: new file / new folder. Ctrl+; toggles the terminal, Ctrl+\ comments a line.
- Font JetBrains Mono, theme One Dark Pro Darker, format on save.
- Cmd+Shift+Space is VS Code's (parameter hints): the key help rule in Karabiner skips VS Code on purpose.

## zathura

Config: `~/.config/zathura/zathurarc`. PDF viewer, opened from nvim and by the `zathura` function in `.zshrc`
(forks and detaches from the terminal). Both bring the new window to the front with a short AppleScript loop,
since zathura has no `.app` and macOS would leave it behind. Selections go to the macOS clipboard. Keys: `keys.md`, Zathura.

## Plain vim

`~/.vimrc`: a fallback for machines or moments without nvim (slate colors, 4-space indents, a few leader maps).
Not used day to day; `vim` and `vi` are aliases for nvim in `.zshrc`.

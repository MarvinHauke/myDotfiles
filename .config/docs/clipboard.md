# Clipboard history

Status: implemented in `~/.hammerspoon/clipboard.lua`.

One OS-wide history. Everything that reaches the macOS clipboard lands in it.

| Source | How it gets there |
|---|---|
| Any app | Cmd+C |
| nvim | `clipboard=unnamedplus` (`nvim/lua/core/options.lua`): yanks and `dd`/`x`/`c` |
| tmux copy mode | `y` pipes to `pbcopy` (`tmux/tmux.conf`) |
| Screenshots | Cmd+Shift+3/4 (see `capture.md`) |

- Store: Hammerspoon pasteboard watcher, last 100 text entries in `~/.local/state/clipboard.json` (mode 600). Copying an old entry again moves it to the top.
- Use: Hyper+v opens the picker, type to filter, Enter pastes into the front app (key in `keys.md`).
- Text only. Entries marked as concealed or transient (password managers) are skipped.
- Clear: `echo '[]' > ~/.local/state/clipboard.json`, then Hyper+r.

Open point: check that a password copied from KeePassXC does not show up.

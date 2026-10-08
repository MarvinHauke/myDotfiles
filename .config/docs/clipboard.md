# Clipboard history

Status: proposal, not implemented yet.

One OS-wide history. Everything that reaches the macOS clipboard lands in it.

| Source | How it gets there |
|---|---|
| Any app | Cmd+C |
| nvim | `clipboard=unnamedplus` (`nvim/lua/core/options.lua`): yanks and `dd`/`x`/`c` |
| tmux copy mode | `y` pipes to `pbcopy` (`tmux/tmux.conf`) |
| Screenshots | Cmd+Shift+3/4 (see `capture.md`) |

- Store: Hammerspoon pasteboard watcher, last ~100 entries in `~/.local/state/clipboard.json`.
- Use: Hyper+v opens the picker, Enter pastes into the front app (key in `keys.md`).

Open points:
- Keep images in the history, or text only?
- Skip passwords copied from KeePassXC.

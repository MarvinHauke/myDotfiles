# Clipboard history

Status: implemented in `~/.hammerspoon/clipboard.lua`.

One OS-wide history. Everything that reaches the macOS clipboard lands in it.

| Source | How it gets there |
|---|---|
| Any app | Cmd+C |
| nvim | `clipboard=unnamedplus` (`nvim/lua/core/options.lua`): yanks and `dd`/`x`/`c` |
| tmux copy mode | `y` pipes to `pbcopy` (`tmux/tmux.conf`) |
| Screenshots | Cmd+Shift+3/4 (see `capture.md`): the path as text, plus a picture row |

- Store: Hammerspoon pasteboard watcher, last 100 text entries in `~/.local/state/clipboard.json` (mode 600). Copying an old entry again moves it to the top.
- Use: Hyper+v opens the picker, type to filter, Enter pastes into the front app (key in `keys.md`).
- Copied content is kept as text only; the one exception is the picture row of a screenshot (below).
- Secrets are not recorded but can still be pasted with Cmd+V: anything copied while Passwords, Keychain Access
  or KeePassXC is in front, and anything a password manager marks as secret (concealed/transient types).
  The app list is `secretApps` in `clipboard.lua`. Not covered: copies from the Passwords menu bar popup while
  another app is in front, unless they carry a secret mark.
- Right-click a row in the picker to delete it from the history.
- Picture rows exist only for screenshots. They point at the file in `/tmp/shots` and disappear from the list
  when macOS has cleaned the file away. They count towards the 100 entries.
- Clear: `echo '[]' > ~/.local/state/clipboard.json`, then Hyper+r.


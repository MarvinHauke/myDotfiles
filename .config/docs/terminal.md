# Terminal (Ghostty and tmux)

Config: `~/.config/ghostty/config`, `~/.config/tmux/tmux.conf`. Keys are listed in `keys.md` under Shell.

## Ghostty

Only what differs from the defaults. All options: `ghostty +show-config --default --docs`.
Check the file: `ghostty +validate-config`. Reload: Cmd+Shift+,.

| Setting | Why |
|---|---|
| theme Catppuccin Mocha | matches tmux and nvim |
| no font set | the built-in JetBrains Mono has the Nerd Font symbols starship and lsd need |
| `confirm-close-surface = false`, `quit-after-last-window-closed` | tmux keeps the sessions, closing a window loses nothing |
| `mouse-hide-while-typing` | |
| `keybind = super+…=text:\x1b…` | Cmd keys for the shell: the terminal never sees Cmd, so Ghostty sends Esc + letter (see `shell.md`) |
| no `macos-option-as-alt` | Option must keep typing @ [ ] \| { } on the German layout |

Replaced Ghostty defaults: Cmd+k (clear screen), Cmd+j (scroll to selection), Cmd+Shift+j (paste the screen as a file).
Current bindings: `ghostty +list-keybinds`.

## tmux

Every Ghostty window attaches to the session `default` (block at the end of `.zshrc`).

| Setting | Value |
|---|---|
| prefix | Ctrl+Space |
| windows and panes | start at 1, renumbered |
| split | prefix `-` side by side, prefix `_` stacked, both in the current folder |
| resize | prefix h/j/k/l (repeatable), prefix m zooms (also Opt+m from Karabiner) |
| copy mode | prefix Esc, vi keys, `v` / `V` select, `y` copies to the clipboard |
| reload | prefix r |
| status bar | `[session +N]` on the left (N = other sessions), windows centered, cpu and memory on the right |

Plugins (tpm, `~/.tmux/plugins/`; install with prefix I, update with prefix U):
tmux-sensible, vim-tmux-navigator (Ctrl+h/j/k/l across tmux and nvim), catppuccin, tmux-yank,
tmux-cpu-mem-monitor, tmux-resurrect and tmux-continuum (sessions survive a restart).

List all keys: prefix `?`.

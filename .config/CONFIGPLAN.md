# Configplan (macOS)

Rules: few tools, open source, plain text config, everything tracked in `dotfiles` (branch `macos`).
Status: [ ] open, [x] done. Keep one line per item. Delete done items after a while.

## Docs

This file: state and open steps. How everything works lives in `docs/`, one file per topic;
the index, the structure diagram and the doc rules are in `docs/README.md`.

## State

| Area        | Tool                                                                                 | Config                                           | State                                                                                           |
| ----------- | ------------------------------------------------------------------------------------ | ------------------------------------------------ | ----------------------------------------------------------------------------------------------- |
| Shell       | zsh + zap (11 plugins), starship                                                     | `~/.zshrc`                                       | good, starts in 0.12 s                                                                          |
| Terminal    | ghostty                                                                              | `ghostty/config`                                 | good, config minimal                                                                            |
| Multiplexer | tmux + tpm (8 plugins)                                                               | `tmux/tmux.conf`                                 | good                                                                                            |
| Editor      | neovim, lazy.nvim, ~40 plugin files                                                  | `nvim/`                                          | good                                                                                            |
| PDF         | zathura                                                                              | `zathura/zathurarc`                              | good                                                                                            |
| Keys        | karabiner (caps = ctrl/esc, ctrl-hjkl), owns all hotkeys                             | `karabiner/`                                     | good                                                                                            |
| Automation  | hammerspoon: launcher, windows, clipboard, Finder keys, help (actions only)          | `~/.hammerspoon/*.lua`                           | new, needs daily use                                                                            |
| Capture     | macOS built-in keys + hammerspoon `capture.lua`                                      | `defaults com.apple.screencapture`, `/tmp/shots` | new                                                                                             |
| Launcher    | hammerspoon `launcher.lua` + `launcher/`, Cmd+Space; `edit` opens files in nvim/tmux | `~/.hammerspoon/`, `~/.local/bin/edit`           | new                                                                                             |
| Windows     | hammerspoon `windows.lua`, AltTab                                                    | `~/.hammerspoon/`                                | new                                                                                             |
| Packages    | Homebrew                                                                             | `brew/Brewfile`                                  | good. Record: `brew bundle dump --force`. Restore: `brew bundle`. Extras: `brew bundle cleanup` |
| Dotfiles    | bare repo `~/.cfg`, branch `macos`                                                   |                                                  | clean                                                                                           |

## 1. Chores (by hand)

- [ ] Restart nvim, then delete `~/.config/nvim\undodir` (recreated by a session started before the fix).
- [ ] Archive the VimAbl repo (has uncommitted work on `refactor/immutable-ast-store`).
- [ ] Empty the Trash when everything works (holds Raycast and its data).
- [ ] Translate, Color Picker, Linear (the last Raycast uses): decide, drop or use the web.

## 2. Try with real keys

Built and tested through the command line, not yet pressed. Confirmed so far: window keys, launcher keys,
shell suggestion keys, the `edit` menu, Finder `e`, `?`, `a`, Ctrl+h.

- [ ] Finder `a` inside an empty folder: the item lands in that folder, not one level up.
- [ ] Clipboard picker: right-click deletes a row.
- [ ] Shell keys (2026-10-29): Cmd+k/j and Ctrl+R (Enter runs, Tab fills), Cmd+Shift+k/j, Esc then Space,
      fzf input on top, Cmd+Shift+j no longer pastes a file path.
- [ ] Key help: Cmd+Shift+Space in Ghostty, Finder, Ableton; VS Code keeps its own Cmd+Shift+Space; Space in the empty launcher.
- [ ] Tab (2026-10-29): takes the grey suggestion, completes without one (also on an empty line); Cmd+Shift+l completes;
      Cmd+j/k and Tab inside the completion list; `vim **` Tab; Opt+Backspace deletes one word; `help`, `?`, `help finder`.
- [ ] Every other key from `docs/keys.md` once.

## 3. Build next

- [ ] `?` for the other layers (for example Hyper+?), a key for `hammerspoon://launcher?q=/`.
- [ ] Optional: images in the terminal. Enable `image` in snacks.nvim (uses `magick`, installed), `set -g allow-passthrough on` in tmux. Shell: `chafa` only if needed.
- [ ] Optional: move zsh into `~/.config/zsh` with `ZDOTDIR` (set in `~/.zshenv`), split `.zshrc` into env / aliases / functions.
- [ ] Later, if needed: sub-calculators (electronics etc.) behind a prefix in the launcher.

## 4. Usage log (lowest priority)

- [ ] CLI: zsh history is already the log. Add a `histstat` function (top commands and subcommands).
- [ ] GUI: `hs.application.watcher` appends `time<TAB>app` to `~/.local/state/applog.tsv`.
- [ ] Review monthly, add findings here.

Until then, from shell history: `cd` 793, `git` 712 (`git commit` 322), `vim` 359, `config` 204
(old name of `dotfiles`), `brew install` 100, `tmux rename-window` 18.

## Done?

- [ ] When all lists above are empty, delete them and rename this file to `~/.config/README.md`.

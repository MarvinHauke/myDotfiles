# Configplan (macOS)

Rules: few tools, open source, plain text config, everything tracked in `dotfiles` (branch `macos`).
Status: [ ] open, [x] done. Keep one line per item. Delete done items after a while.

## Docs

This file: overview, state, open steps. Details live in `docs/`, one file per topic.
New topic = new file there plus one line here.

| Doc                 | Answers                                                                              |
| ------------------- | ------------------------------------------------------------------------------------ |
| `docs/keys.md`      | which key does what, which layer a new key belongs to                                |
| `docs/capture.md`   | screenshots and recording: keys, commands, where files go                            |
| `docs/launcher.md`  | what the launcher finds, how files and folders are opened in nvim, Finder or Ghostty |
| `docs/clipboard.md` | what feeds the clipboard history, where it is stored, how to pick from it            |

## Structure

Who calls whom, and where it is configured.

    Karabiner: all hotkeys             karabiner/karabiner.json      docs/keys.md
      |- Hammerspoon                   ~/.hammerspoon/*.lua          launcher, windows, clipboard, help
          |- launcher sources          ~/.hammerspoon/launcher/      apps, paths, calc, usage  docs/launcher.md
          |- edit                      ~/.local/bin/edit             files into nvim/tmux    docs/launcher.md
      |- Finder keys                   finder.lua sets finder_editing docs/keys.md
      |- tmux pane zoom, cmdAbl        karabiner/assets/complex_modifications/

    Ghostty                            ghostty/config
      |- zsh                           ~/.zshenv > ~/.zprofile > ~/.zshrc
          |- starship                  starship/starship.toml
          |- zap plugins, fzf, zoxide, direnv   (set up in ~/.zshrc)
          |- tmux                      tmux/tmux.conf (tpm plugins)
              |- nvim                  nvim/ (lazy.nvim), panes shared via vim-tmux-navigator
                  |- zathura           zathura/zathurarc (PDFs opened from nvim)

    macOS screenshot keys              defaults com.apple.screencapture   docs/capture.md
      |- Hammerspoon capture.lua       watches /tmp/shots, path to clipboard

    Homebrew installs all of it        brew/Brewfile (HOMEBREW_BUNDLE_FILE in ~/.zshrc)
    dotfiles (~/.cfg, branch macos) tracks all of it

Hotkeys live only in `karabiner.json`. Hammerspoon exposes actions (`hs.urlevent.bind` in `init.lua`);
Karabiner calls `open -g hammerspoon://<action>`. Keys inside one app may live in that app's config (Ghostty).
Secrets go in `~/.env` or `~/.zshrc.local` (both ignored by git), never in a tracked file.

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

Built and tested through the command line, not yet pressed. Working so far: window keys, Finder `e`.

- [x] Finder: `?` shows the keys, any key closes the panel.
- [x] Launcher: Enter and Cmd+Enter on a file row, Tab on a folder row.
- [x] Shell: Cmd+l takes the next word of the grey suggestion, Cmd+Shift+l all of it.
- [ ] `edit` menu: open the same folder twice from the launcher (for example `dev`), the second time the menu appears.
- [ ] Clipboard picker: right-click deletes a row.
- [ ] Every other key from `docs/keys.md` once.

## 3. Build next

- [x] `edit`: a folder that a tmux pane already sits in brings up a menu: go there or open a new window (`docs/launcher.md`).
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

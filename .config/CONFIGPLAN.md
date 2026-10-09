# Configplan (macOS)

Rules: few tools, open source, plain text config, everything tracked in `dotfiles` (branch `macos`).
Status: [ ] open, [x] done. Keep one line per item. Delete done items after a while.

## Docs

This file: overview, state, open steps. Details live in `docs/`, one file per topic.
New topic = new file there plus one line here.

| Doc | Answers |
|---|---|
| `docs/keys.md` | which key does what, which layer a new key belongs to |
| `docs/capture.md` | screenshots and recording: keys, commands, where files go |
| `docs/launcher.md` | what the launcher finds, how files and folders are opened in nvim, Finder or Ghostty |
| `docs/clipboard.md` | what feeds the clipboard history, where it is stored, how to pick from it |

## Structure

Who calls whom, and where it is configured.

    Karabiner: all hotkeys             karabiner/karabiner.json      docs/keys.md
      |- Hammerspoon                   ~/.hammerspoon/*.lua          launcher, windows, clipboard, help
          |- launcher sources          ~/.hammerspoon/launcher/      apps, paths, calc       docs/launcher.md
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

## State

| Area | Tool | Config | State |
|---|---|---|---|
| Shell | zsh + zap (11 plugins), starship | `~/.zshrc` | good, starts in 0.12 s |
| Terminal | ghostty | `ghostty/config` | good, config minimal |
| Multiplexer | tmux + tpm (8 plugins) | `tmux/tmux.conf` | good |
| Editor | neovim, lazy.nvim, ~40 plugin files | `nvim/` | good |
| PDF | zathura | `zathura/zathurarc` | good |
| Keys | karabiner (caps = ctrl/esc, ctrl-hjkl), owns all hotkeys | `karabiner/` | good |
| Automation | hammerspoon: launcher, windows, clipboard, Finder keys, help (actions only) | `~/.hammerspoon/*.lua` | new, needs daily use |
| Capture | macOS built-in keys + hammerspoon `capture.lua` | `defaults com.apple.screencapture`, `/tmp/shots` | new |
| Launcher | hammerspoon `launcher.lua` + `launcher/`, Cmd+Space; `edit` opens files in nvim/tmux | `~/.hammerspoon/`, `~/.local/bin/edit` | new |
| Windows | hammerspoon `windows.lua`, AltTab | `~/.hammerspoon/` | new |
| Packages | Homebrew | `brew/Brewfile` | good, `brew bundle dump --force` after changes |
| Dotfiles | bare repo `~/.cfg`, branch `macos` | | clean |

## 1. Fix (broken or wrong today)

- [x] nvim undodir: custom path removed, 919 undo files moved to `~/.local/state/nvim/undo`.
- [x] zsh: `top=htop` alias removed (htop not installed).
- [x] zsh: `GITHUB_TOKEN` exports removed from `.zshrc` and `.zshenv`, `gh` uses the keyring.
- [x] zsh: zoxide warning does not appear in a fresh interactive shell.
- [x] dotfiles: committed as `79f7d11` on `macos`.
- [ ] `dotfiles push`.
- [x] Token files `~/.ssh/GithubTokens` and `~/.config/github/` deleted, classic tokens revoked on GitHub.

## 2. Remove (fewer tools)

- [x] iTerm2 and kitty uninstalled with their settings.
- [x] MacPorts: PATH block removed from `.zprofile`.
- [x] MacPorts removed: `/opt/local`, the `macports` user and group.
- [x] Strays trashed: `package.json`, `package-lock.json`, `zsh/`. `gtk-3.0` kept (GTK apps recreate it).
- [x] `.zshenv`: project venv argcomplete path removed.
- [x] VimAbl: Hammerspoon requires and `keys` symlink, LaunchAgent `com.vimforlive.osc-bridge`, Remote Script symlink removed.
- [x] Karabiner "Ctrl+Minus opens browser" kept (plain remap to Ableton's Cmd+Opt+5, no VimAbl dependency).
- [ ] Archive the VimAbl repo (has uncommitted work on `refactor/immutable-ast-store`).
- [ ] Restart nvim, then delete `~/.config/nvim\undodir` (recreated by a session started before the fix).

## 3. Replace Raycast with Hammerspoon

Hotkeys live in Karabiner (`karabiner.json` only, no catalog copy).
Hammerspoon only exposes actions (`hs.urlevent.bind` in `init.lua`); Karabiner calls `open -g hammerspoon://<action>`.

- [x] Launcher with calculator (`launcher.lua`, Cmd+Space, `=` prefix calculates).
- [x] Window keys and focus toggle (`windows.lua`, Opt+Shift+hjkl/m, Opt+m).
- [x] Clipboard history (`clipboard.lua`, Hyper+v, text only, skips concealed entries).
- [x] Hyper = right Cmd; reload on Hyper+r, app name on Hyper+i.
- [x] `fkill` and `fbrew` in `.zshrc` replace the Kill Process and Brew extensions.
- [x] Raycast quit, login item removed, app and data in the Trash.
- [ ] Try every key from `docs/keys.md` once; the rules are linted but were not tested with real key presses.
- [ ] Empty the Trash when everything works.
- [ ] Translate, Color Picker, Linear: decide, drop or use the web.
- [x] AltTab stays (window switching).
- [ ] Later, if needed: sub-calculators (electronics etc.) behind a prefix.

## 4. Track and reproduce

- [x] `brew/Brewfile` replaces the two package lists. Record: `brew bundle dump --force`. Restore: `brew bundle`. Extras: `brew bundle cleanup`.
- [x] Install script (GitHub gist) runs `brew bundle --file ~/.config/brew/Brewfile`; falls back to `packages.txt` on branches without a Brewfile.
- [x] `.zshenv` and `.zprofile` are tracked (`.zshenv` no longer fails without rustup).
- [x] ghostty: `ghostty/config` holds every non-default setting (theme, close without asking, hide mouse). Font and keys are the defaults.
- [ ] Optional: images in the terminal. Enable `image` in snacks.nvim (uses `magick`, installed), `set -g allow-passthrough on` in tmux. Shell: `chafa` only if needed.
- [ ] Optional: move zsh into `~/.config/zsh` with `ZDOTDIR` (set in `~/.zshenv`), split `.zshrc` into env / aliases / functions.

## 5. Keys and capture

Details and proposals live in `docs/`. This file only tracks the steps.

- [x] Desktops: dropped. AltTab, tmux windows and the launcher cover switching; no fixed desktops.
- [x] Capture: built-in keys save to `/tmp/shots`, path goes to the clipboard (`capture.lua`, `docs/capture.md`).
- [x] The install script sets the two `defaults write com.apple.screencapture` lines from `docs/capture.md`.

## 6. Usage log (lowest priority)

- [ ] CLI: zsh history is already the log. Add a `histstat` function (top commands and subcommands).
- [ ] GUI: `hs.application.watcher` appends `time<TAB>app` to `~/.local/state/applog.tsv`.
- [ ] Review monthly, add findings here.

Until then, from shell history: `cd` 793, `git` 712 (`git commit` 322), `vim` 359, `config` 204
(old name of `dotfiles`), `brew install` 100, `tmux rename-window` 18.

## 7. Open files and folders (`docs/launcher.md`)

- [x] `~/.local/bin/edit <file>`: split in a running nvim of the project, else a tmux window or session. Ghostty to front.
- [x] Finder: `e` opens the selection with `edit`, `?` shows the Finder keys (read from `docs/keys.md`).
- [x] Launcher: recent files (nvim) and folders (zoxide) below the apps; `/` searches with fd + fzf; Cmd+Enter shows in Finder.
- [x] `e` in Finder works (tried with real keys).
- [ ] Try the real keys: `?` in Finder, Enter and Cmd+Enter on a file row, Tab on a folder row.
- [ ] Idea: when a tmux pane or window already sits in the chosen path, `edit` asks: focus the existing one or open a new window.
- [ ] Later: `?` for the other layers (for example Hyper+?), a key for `hammerspoon://launcher?q=/`.

## Done?

- [ ] When all lists above are empty, delete them and rename this file to `~/.config/README.md`.

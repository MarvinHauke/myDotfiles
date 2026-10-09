# Configplan (macOS)

Rules: few tools, open source, plain text config, everything tracked in `dotfiles` (branch `macos`).
Status: [ ] open, [x] done. Keep one line per item. Delete done items after a while.

## Docs

This file: overview, state, open steps. Details live in `docs/`, one file per topic.
New topic = new file there plus one line here.

| Doc | Answers |
|---|---|
| `docs/keys.md` | which key does what, which layer a new key belongs to |
| `docs/desktops.md` | which app lives on which desktop, how tmux fits in |
| `docs/capture.md` | screenshots and recording: keys, commands, where files go |
| `docs/clipboard.md` | what feeds the clipboard history, where it is stored, how to pick from it |

## Structure

Who calls whom, and where it is configured. `*` = planned, not built yet.

    Karabiner: all hotkeys             karabiner/karabiner.json      docs/keys.md
      |- Hammerspoon                   ~/.hammerspoon/*.lua          launcher, windows, clipboard
      |- Finder keys                   finder.lua sets finder_editing docs/keys.md
      |- macOS Spaces *                System Settings               docs/desktops.md
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

    Homebrew installs all of it        brew/
    dotfiles (~/.cfg, branch macos) tracks all of it

## State

| Area | Tool | Config | State |
|---|---|---|---|
| Shell | zsh + zap (11 plugins), starship | `~/.zshrc` | good, starts in 0.12 s |
| Terminal | ghostty | `ghostty/config` (1 line) | good, config minimal |
| Multiplexer | tmux + tpm (8 plugins) | `tmux/tmux.conf` | good |
| Editor | neovim, lazy.nvim, ~40 plugin files | `nvim/` | good |
| PDF | zathura | `zathura/zathurarc` | good |
| Keys | karabiner (caps = ctrl/esc, ctrl-hjkl), owns all hotkeys | `karabiner/` | good |
| Automation | hammerspoon: launcher, windows, clipboard (actions only) | `~/.hammerspoon/*.lua` | new, needs daily use |
| Capture | macOS built-in keys + hammerspoon `capture.lua` | `defaults com.apple.screencapture`, `/tmp/shots` | new |
| Launcher | hammerspoon `launcher.lua`, Cmd+Space | `~/.hammerspoon/` | new |
| Windows | hammerspoon `windows.lua`, AltTab | `~/.hammerspoon/` | new |
| Packages | Homebrew (53 formulae, 9 casks) | `brew/*.txt` | list is stale |
| Dotfiles | bare repo `~/.cfg` | | clean, 1 commit unpushed |

## 1. Fix (broken or wrong today)

- [x] nvim undodir: custom path removed, 919 undo files moved to `~/.local/state/nvim/undo`.
- [x] zsh: `top=htop` alias removed (htop not installed).
- [x] zsh: `GITHUB_TOKEN` exports removed from `.zshrc` and `.zshenv`, `gh` uses the keyring.
- [x] zsh: zoxide warning does not appear in a fresh interactive shell.
- [x] dotfiles: committed as `79f7d11` on `macos`.
- [ ] `dotfiles push`.
- [ ] Delete the unused token files `~/.ssh/GithubTokens` and `~/.config/github/token`, revoke the token on GitHub.

## 2. Remove (fewer tools)

- [x] iTerm2 and kitty uninstalled with their settings.
- [x] MacPorts: PATH block removed from `.zprofile`.
- [ ] MacPorts files (needs sudo): `sudo rm -rf /opt/local /Applications/MacPorts /Library/Tcl/macports1.0 && sudo dscl . -delete /Users/macports && sudo dscl . -delete /Groups/macports`
- [x] Strays trashed: `package.json`, `package-lock.json`, `zsh/`. `gtk-3.0` kept (GTK apps recreate it).
- [x] `.zshenv`: project venv argcomplete path removed.
- [x] VimAbl: Hammerspoon requires and `keys` symlink, LaunchAgent `com.vimforlive.osc-bridge`, Remote Script symlink removed.
- [x] Karabiner "Ctrl+Minus opens browser" kept (plain remap to Ableton's Cmd+Opt+5, no VimAbl dependency).
- [ ] Archive the VimAbl repo (has uncommitted work on `refactor/immutable-ast-store`).
- [ ] Restart nvim, then delete `~/.config/nvim\undodir` (recreated by a session started before the fix).

## 3. Replace Raycast with Hammerspoon

Hotkeys live in Karabiner (`karabiner.json`, catalog copy in `assets/complex_modifications/hammerspoon.json`).
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
- [ ] Check whether AltTab is still needed.
- [ ] Later, if needed: sub-calculators (electronics etc.) behind a prefix.

## 4. Track and reproduce

- [ ] Replace `brew/packages.txt` and `cask-packages.txt` (18 entries, wrong names like `rg`, `nvim`) with a `Brewfile` from `brew bundle dump`. Update the install script.
- [ ] Track `.zshenv` and `.zprofile`.
- [ ] ghostty: move font, keybinds and window settings into `ghostty/config`.
- [ ] Optional: images in the terminal. Enable `image` in snacks.nvim (uses `magick`, installed), `set -g allow-passthrough on` in tmux. Shell: `chafa` only if needed.
- [ ] Optional: move zsh into `~/.config/zsh` with `ZDOTDIR` (set in `~/.zshenv`), split `.zshrc` into env / aliases / functions.

## 5. Keys, desktops, capture

Details and proposals live in `docs/`. This file only tracks the steps.

- [ ] Desktops: set up the 6 fixed desktops, native Spaces first (`docs/desktops.md`).
- [x] Capture: built-in keys save to `/tmp/shots`, path goes to the clipboard (`capture.lua`, `docs/capture.md`).
- [ ] Add the two `defaults write com.apple.screencapture` lines from `docs/capture.md` to the install script.

## 6. Usage log (lowest priority)

- [ ] CLI: zsh history is already the log. Add a `histstat` function (top commands and subcommands).
- [ ] GUI: `hs.application.watcher` appends `time<TAB>app` to `~/.local/state/applog.tsv`.
- [ ] Review monthly, add findings here.

Until then, from shell history: `cd` 793, `git` 712 (`git commit` 322), `vim` 359, `config` 204
(old name of `dotfiles`), `brew install` 100, `tmux rename-window` 18.

## Done?

- [ ] When all lists above are empty, delete them and rename this file to `~/.config/README.md`.

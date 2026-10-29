---
name: dotfiles-docs
description: Keep ~/.config/docs/ in sync when changing the user's dotfiles (zsh, Ghostty, tmux, nvim, Hammerspoon, Karabiner, brew, git hooks, tracked in the bare repo ~/.cfg). Use before editing or committing any of those config files, or when asked to document them.
---

# Dotfiles docs

The config is tracked in a bare repo: `git --git-dir=$HOME/.cfg --work-tree=$HOME` (the user's shell
function is `dotfiles`; always call it that in instructions). Branch on this Mac: `macos`.
Every config change gets its doc change in the same commit. The pre-commit hook warns when it is missing.

## Where things are documented

Read `~/.config/docs/README.md` first: index, "who calls whom" diagram, rules.

| Config changed | Update |
|---|---|
| any key binding (Karabiner, Ghostty `keybind`, zsh `bindkey`, Hammerspoon key handling, tmux keys) | `keys.md`, plus the tool's doc |
| `~/.zshrc`, `~/.zshenv`, `~/.zprofile`, `starship/` | `shell.md` |
| `ghostty/config`, `tmux/tmux.conf` | `terminal.md` |
| `nvim/` | `nvim.md` |
| `~/.hammerspoon/` (new `hammerspoon://` action, module) | `hammerspoon.md`; launcher → `launcher.md`, clipboard → `clipboard.md`, capture → `capture.md` |
| `karabiner/karabiner.json` | `keys.md` |
| `brew/Brewfile`, repo, branches, install, git hooks, secrets | `dotfiles.md` |
| new topic | new file in `docs/` + one row in the table in `docs/README.md` |

Open steps and state go in `~/.config/CONFIGPLAN.md`, not in the docs. `~/README.md` is the GitHub
front page: install and links only.

## Rules

- Keys are listed only in `keys.md`, in a `| Key | Action | ... |` table under `## <topic>`. The help panel
  (`~/.hammerspoon/help.lua`) shows the first table under a heading: keep that table the key list, details below it.
  Other docs link to `keys.md` and don't repeat keys.
- Describe what is there now, not the history of how it got there. Remove lines that no longer hold.
- Match the existing style: short sentences, tables for lists of things, file paths in backticks.
- Check claims against the config (grep it) before writing them.
- Commit only when the user asks; then `dotfiles add` new doc files too.

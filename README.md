# myDotfiles — macOS

## Overview

Configured as a git bare repo for easy migration to new machines.
For details on how to clone this repo take a look at: [git bare repo for dotfiles](https://www.atlassian.com/git/tutorials/dotfiles "go to the article")

## Install

```bash
curl -fsSL https://gist.github.com/MarvinHauke/3cd5967bf33fee9350d1fc552138e08e/raw | bash
```

The script will:

1. Clone the bare repo to `~/.cfg`
2. Back up any conflicting files to `~/.dotfiles-backup`
3. Check out the `macos` branch
4. Install everything listed in `~/.config/brew/Brewfile` (`brew bundle`)

## Docs

How each part is set up, which key does what and who calls whom: [`.config/docs/`](.config/docs/README.md).

| Doc | Covers |
|---|---|
| [keys](.config/docs/keys.md) | every hotkey, by layer |
| [shell](.config/docs/shell.md) | zsh, plugins, shell keys, starship |
| [terminal](.config/docs/terminal.md) | Ghostty, tmux |
| [nvim](.config/docs/nvim.md) | neovim layout, plugins, LSP |
| [hammerspoon](.config/docs/hammerspoon.md) | launcher, windows, clipboard, key help |
| [dotfiles](.config/docs/dotfiles.md) | this repo, branches, Homebrew, secrets |
| [apps](.config/docs/apps.md) | VS Code, zathura, plain vim |

## Package lists

| File                      | Contents                                             |
| ------------------------- | ---------------------------------------------------- |
| `~/.config/brew/Brewfile` | taps, CLI tools, GUI apps, global go/cargo/npm tools |

`brew bundle dump --force` records the installed state, `brew bundle` restores it,
`brew bundle cleanup` lists what is installed but not in the file.

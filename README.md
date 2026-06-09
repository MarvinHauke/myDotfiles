# myDotfiles

## Overview

Configured as a git bare repo for easy migration to new machines.
For details on how to clone this repo take a look at: [git bare repo for dotfiles](https://www.atlassian.com/git/tutorials/dotfiles "go to the article")

> **Install script preview:** [gist.github.com/MarvinHauke/3cd5967bf33fee9350d1fc552138e08e](https://gist.github.com/MarvinHauke/3cd5967bf33fee9350d1fc552138e08e)

## Branches

The install script auto-detects your OS/architecture and checks out the matching branch:

| Branch | Target |
|---|---|
| `macos` | macOS (Homebrew + cask packages) |
| `linux` | Linux x86\_64 (Homebrew packages) |
| `raspbian` | Raspberry Pi / ARM64 Linux (apt, minimal setup) |
| `linux-android` | Android via Termux |
| `main` | Fallback |

## Install

On a fresh machine, bootstrap with a single curl command:

```bash
curl -fsSL https://raw.githubusercontent.com/MarvinHauke/myDotfiles/main/.config/myDotfiles_install.sh | bash
```

Or manually:

```bash
chmod +x .config/myDotfiles_install.sh
. ./.config/myDotfiles_install.sh
```

The script will:
1. Clone the bare repo to `~/.cfg`
2. Detect your OS and check out the correct branch
3. Install packages (Homebrew on macOS/Linux, apt on Raspbian)

## Config files

### Neovim
```
~/.config/nvim/
```
- `init.lua` — bootstraps Lazy.nvim
- `lua/plugins/` — plugin specs
- `ftplugin/` — filetype-specific settings

### Zsh
```
~/.zshrc
```
- Path aliases
- Utility functions

### Starship
```
~/.config/starship/starship.toml
```

### Ghostty
```
~/.config/ghostty/config
```

### Tmux
```
~/.config/tmux/tmux.conf
```

## Raspbian / Minimal setup (ARM64)

The `raspbian` branch targets Raspberry Pi 3+ and other ARM64 Linux devices.
It installs a lightweight subset via `apt` — no Homebrew, no macOS-specific tools.

Packages are listed in `~/.config/apt/packages.txt`.

> **Note:** `starship` and `zoxide` are not in standard apt repos — install them via their upstream curl scripts after running the dotfiles install.

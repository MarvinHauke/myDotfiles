# myDotfiles

## Overview

Configured as a git bare repo for easy migration to new machines.
For details on how to clone this repo take a look at: [git bare repo for dotfiles](https://www.atlassian.com/git/tutorials/dotfiles "go to the article")

## Branches

The install script auto-detects your OS/architecture and checks out the matching branch:

| Branch | Target |
|---|---|
| `macos` | macOS (Homebrew + cask packages) |
| `linux` | Linux x86\_64 (Homebrew packages) |
| `raspbian` | Raspberry Pi / ARM64 Linux (apt + starship + zoxide) |
| `linux-android` | Android via Termux |
| `Windows_NT` | Windows (Chocolatey + PowerShell modules) |
| `main` | Fallback |

## Install

### macOS / Linux / Raspberry Pi

```bash
curl -fsSL https://gist.github.com/MarvinHauke/3cd5967bf33fee9350d1fc552138e08e/raw | bash
```

### Windows (PowerShell)

> Run PowerShell as Administrator

```powershell
irm https://gist.github.com/MarvinHauke/5594644ca1f4dcd3122d705481ccccb2/raw | iex
```

The script will:
1. Clone the bare repo to `~/.cfg`
2. Detect your OS and check out the correct branch
3. Install packages for your platform

## Config files

### Neovim
```
~/.config/nvim/          (Linux/macOS)
~/AppData/Local/nvim/    (Windows)
```
- `init.lua` — bootstraps Lazy.nvim
- `lua/plugins/` — plugin specs
- `ftplugin/` — filetype-specific settings

### Shell
```
~/.zshrc       (macOS)
~/.bashrc      (Linux / Raspberry Pi)
~/Documents/PowerShell/Microsoft.PowerShell_profile.ps1  (Windows)
```

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

## Package lists

Each branch keeps its package list under `~/.config/<manager>/packages.txt`:

| Branch | Manager | File |
|---|---|---|
| `macos` | Homebrew | `~/.config/brew/packages.txt` + `cask-packages.txt` |
| `linux` | Homebrew | `~/.config/brew/packages.txt` |
| `raspbian` | apt | `~/.config/apt/packages.txt` |
| `Windows_NT` | Chocolatey | `~/.config/choco/packages.txt` |

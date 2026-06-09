# myDotfiles — Android / Termux

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
3. Check out the `linux-android` branch

> **Note:** No package manager installs are automated for Termux — install packages manually via `pkg install`.

## Config files

### Bash
```
~/.bashrc
~/.bash_aliases
~/.profile
```

### Neovim
```
~/.config/nvim/
```
- `init.lua` — bootstraps Lazy.nvim
- `lua/plugins/` — minimal plugin set for Termux
- `ftplugin/` — filetype-specific settings

### VS Code
```
~/.config/Code/User/settings.json
~/.config/Code/User/keybindings.json
```

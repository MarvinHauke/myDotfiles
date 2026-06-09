# myDotfiles — Raspberry Pi / ARM64 Linux

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
3. Check out the `raspbian` branch
4. Install apt packages from `~/.config/apt/packages.txt`
5. Install starship via upstream curl script
6. Install zoxide via upstream curl script

## Config files

### Bash
```
~/.bashrc
~/.bash_aliases
```

### Neovim
```
~/.config/nvim/
```
- `init.lua` — bootstraps Lazy.nvim
- `lua/plugins/` — plugin specs (minimal set for ARM64)
- `ftplugin/` — filetype-specific settings

### VS Code
```
~/.config/Code/User/settings.json
~/.config/Code/User/keybindings.json
```

## Package list

Add apt package names (one per line) to:
```
~/.config/apt/packages.txt
```

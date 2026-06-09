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
4. Install Homebrew packages from `~/.config/brew/packages.txt`
5. Install Homebrew cask packages from `~/.config/brew/cask-packages.txt`

## Config files

### Zsh
```
~/.zshrc
```

### Neovim
```
~/.config/nvim/
```
- `init.lua` — bootstraps Lazy.nvim
- `lua/plugins/` — full plugin set (LSP, DAP, formatting, AI, etc.)
- `lua/plugins/lsp/` — per-language LSP configs (bash, C, Python, Rust, JS, Lua, web)
- `ftplugin/` — filetype-specific settings

### Starship
```
~/.config/starship/starship.toml
```

### Tmux
```
~/.config/tmux/tmux.conf
```

### Ghostty
```
~/.config/ghostty/config
```

### Karabiner-Elements
```
~/.config/karabiner/karabiner.json
~/.config/karabiner/assets/complex_modifications/
```

### Hammerspoon
```
~/.hammerspoon/init.lua
```

### Zathura
```
~/.config/zathura/zathurarc
```

### VS Code
```
~/.config/Code/User/settings.json
~/.config/Code/User/keybindings.json
```

## Package lists

| File | Contents |
|---|---|
| `~/.config/brew/packages.txt` | CLI tools via `brew install` |
| `~/.config/brew/cask-packages.txt` | GUI apps via `brew install --cask` |

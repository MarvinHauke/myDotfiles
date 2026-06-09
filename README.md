# myDotfiles — Windows

## Overview

Configured as a git bare repo for easy migration to new machines.
For details on how to clone this repo take a look at: [git bare repo for dotfiles](https://www.atlassian.com/git/tutorials/dotfiles "go to the article")

## Install

> Run PowerShell as Administrator

```powershell
irm https://gist.github.com/MarvinHauke/5594644ca1f4dcd3122d705481ccccb2/raw | iex
```

The script will:
1. Clone the bare repo to `~/.cfg`
2. Back up any conflicting files to `~/.dotfiles-backup`
3. Check out the `Windows_NT` branch
4. Install Chocolatey (if not present)
5. Install packages from `~/.config/choco/packages.txt`
6. Install required PowerShell modules (`posh-git`, `PSReadLine`, `PSScriptAnalyzer`, `PSFzf`)

**Prerequisite:** Git must be installed before running the script.

## Config files

### PowerShell
```
~/Documents/PowerShell/Microsoft.PowerShell_profile.ps1
```
- Vi mode with cursor change indicator
- `cfg` / `config` function for managing dotfiles
- `sudo` / `admin` for elevated commands
- `which`, `grep`, `find-file` Unix-style helpers
- `cdd` — jump to `~/Development/<dir>`
- Fzf integration via PSFzf
- Lemonade clipboard server auto-start

### Neovim
```
~/AppData/Local/nvim/
```
- `init.lua` — bootstraps Lazy.nvim
- `lua/plugins/` — plugin specs
- `ftplugin/` — filetype-specific settings

### VS Code
```
~/AppData/Roaming/Code/User/settings.json
~/AppData/Roaming/Code/User/keybindings.json
```

## Package list

Add Chocolatey package names (one per line) to:
```
~/.config/choco/packages.txt
```

The install script reads this file and runs `choco install` for each entry.

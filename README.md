# myDotfiles

## Overview
It is configuered as a git bare repo to make it easier to move to new machines.
For details how to clone this Repo to your machine take a look at the following artikel: [git bare repo for dotfiles](https://www.atlassian.com/git/tutorials/dotfiles "go to the artikel")

## install

```bash
chmod +x .config/my-dotfiles_install.sh
. ./.config/my-dotfiles_install.sh
```
this will run the install script for my dotfiles


### Vim:
you can find all related vim files in the following directory

```bash
~/.config/nvim/

```
it contains:
- init.lua for loading Lazy and initializing nvim
- lua/Plugins with the plugins I use
- ftplugins for filetype plugin configuration


### Zsh:
```bash
~/.zshrc
```

it contains:
- aliases I use for often use paths
- functions I use for often use commands


### Starship:
```Bash
~/.config/starship/starship.toml
```
this contains my configured prompt


### Ghostty:
```Bash
~/.config/ghostty/conf
```
this contains my configured ghostty

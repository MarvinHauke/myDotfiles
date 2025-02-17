#!/bin/bash

# Clone the bare repo
git clone --bare git@github.com:MarvinHauke/myDotfiles.git $HOME/.cfg

# Source the correct shell configuration
if [[ "$SHELL" =~ "zsh" ]]; then
    shell_config="$HOME/.zshrc"
else
    shell_config="$HOME/.bashrc"
fi

# Set up the alias
alias config='git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
echo "alias config='git --git-dir=$HOME/.cfg/ --work-tree=$HOME'" >> $shell_config
source "$shell_config"

# Hide untracked files using git directly (instead of alias) to avoid alias issues
git --git-dir=$HOME/.cfg/ --work-tree=$HOME config --local status.showUntrackedFiles no

# Hide untracked files
# config config --local status.showUntrackedFiles no

# Detect OS Type and checkout the corresponding branch
if [[ "$OSTYPE" == "linux-android"* ]]; then
    branch="linux-android"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    branch="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    branch="macos"
else
    echo "Unknown OS, defaulting to 'main'"
    branch="main"
fi

# Checkout and pull the branch using 'git' directly instead of 'config'
git --git-dir=$HOME/.cfg/ --work-tree=$HOME checkout "$branch" || echo "Branch $branch does not exist."
git --git-dir=$HOME/.cfg/ --work-tree=$HOME pull origin "$branch"

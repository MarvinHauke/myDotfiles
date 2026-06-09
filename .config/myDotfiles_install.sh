#!/bin/bash

# Clone the bare repo (SSH preferred, HTTPS fallback for machines without SSH keys)
git clone --bare git@github.com:MarvinHauke/myDotfiles.git "$HOME"/.cfg 2>/dev/null \
    || git clone --bare https://github.com/MarvinHauke/myDotfiles.git "$HOME"/.cfg

# Source the correct shell configuration
if [[ "$SHELL" =~ "zsh" ]]; then
    shell_config="$HOME/.zshrc"
else
    shell_config="$HOME/.bashrc"
fi

# Set up the alias
alias config='git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
echo "alias config='git --git-dir=$HOME/.cfg/ --work-tree=$HOME'" >>"$shell_config"
# shellcheck source=$HOME/.bashrc
source "$shell_config"

# Hide untracked files
git --git-dir="$HOME"/.cfg/ --work-tree="$HOME" config --local status.showUntrackedFiles no

# Detect OS Type and checkout the corresponding branch
if [[ "$OSTYPE" == "linux-android"* ]]; then
    branch="linux-android"
elif [[ "$OSTYPE" == "linux-gnu"* ]] && [[ "$(uname -m)" == "aarch64" ]]; then
    branch="raspbian"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    branch="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    branch="macos"
else
    echo "Unknown OS, defaulting to 'main'"
    branch="main"
fi

# Checkout and pull the branch
git --git-dir="$HOME"/.cfg/ --work-tree="$HOME" checkout "$branch" || echo "Branch $branch does not exist."
git --git-dir="$HOME"/.cfg/ --work-tree="$HOME" pull origin "$branch"

# Install Homebrew packages (macOS / linux only)
if [[ "$branch" == "macos" || "$branch" == "linux" ]]; then
    if [[ -f "$HOME/.config/brew/packages.txt" ]]; then
        echo "Installing Brew packages..."
        xargs brew install <"$HOME/.config/brew/packages.txt"
    else
        echo "No package list found at ~/.config/brew/packages.txt"
    fi
fi

# Install Homebrew cask packages (macOS only)
if [[ "$branch" == "macos" ]]; then
    if [[ -f "$HOME/.config/brew/cask-packages.txt" ]]; then
        echo "Installing Brew Cask packages..."
        xargs brew install --cask <"$HOME/.config/brew/cask-packages.txt"
    else
        echo "No cask package list found at ~/.config/brew/cask-packages.txt"
    fi
fi

# Install apt packages (raspbian only)
if [[ "$branch" == "raspbian" ]]; then
    if [[ -f "$HOME/.config/apt/packages.txt" ]]; then
        echo "Installing apt packages..."
        xargs sudo apt install -y <"$HOME/.config/apt/packages.txt"
    else
        echo "No package list found at ~/.config/apt/packages.txt"
    fi

    echo "Installing starship..."
    curl -sS https://starship.rs/install.sh | sh -s -- --yes

    echo "Installing zoxide..."
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
fi

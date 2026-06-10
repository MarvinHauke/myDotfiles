#!/bin/bash

# Clone the bare repo (SSH preferred, HTTPS fallback for machines without SSH keys)
git clone --bare git@github.com:MarvinHauke/myDotfiles.git "$HOME"/.cfg 2>/dev/null \
    || git clone --bare https://github.com/MarvinHauke/myDotfiles.git "$HOME"/.cfg

cfg_git() { git --git-dir="$HOME/.cfg/" --work-tree="$HOME" "$@"; }

# Configure proper fetch refspec so all remote-tracking branches exist after fetch
cfg_git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
cfg_git config pull.rebase false
cfg_git fetch origin

# Hide untracked files
cfg_git config --local status.showUntrackedFiles no

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

# Source the correct shell configuration
if [[ "$SHELL" =~ "zsh" ]]; then
    shell_config="$HOME/.zshrc"
else
    shell_config="$HOME/.bashrc"
fi

# Checkout branch, backing up any conflicting files first
if ! cfg_git checkout "$branch" 2>/dev/null; then
    backup_dir="$HOME/.dotfiles-backup"
    echo "Backing up conflicting files to $backup_dir..."
    cfg_git checkout "$branch" 2>&1 \
        | grep -E "^\s+\S" | awk '{print $1}' | while IFS= read -r file; do
            mkdir -p "$backup_dir/$(dirname "$file")"
            mv "$HOME/$file" "$backup_dir/$file"
            echo "  Backed up: $file"
        done
    cfg_git checkout "$branch" || { echo "Error: checkout of $branch failed."; exit 1; }
fi

# Set upstream tracking and pull latest
cfg_git branch --set-upstream-to="origin/$branch" "$branch"
cfg_git pull --ff-only

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

# Install apt packages + tools (raspbian only)
if [[ "$branch" == "raspbian" ]]; then
    if [[ -f "$HOME/.config/apt/packages.txt" ]]; then
        echo "Installing apt packages..."
        xargs sudo apt install -y <"$HOME/.config/apt/packages.txt"
    else
        echo "No package list found at ~/.config/apt/packages.txt"
    fi

    echo "Installing starship..."
    curl -sS https://starship.rs/install.sh | sh -s -- --yes
    grep -qF 'starship init bash' "$shell_config" \
        || echo 'eval "$(starship init bash)"' >>"$shell_config"

    echo "Installing zoxide..."
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
    grep -qF 'zoxide init bash' "$shell_config" \
        || echo 'eval "$(zoxide init bash)"' >>"$shell_config"

    # Ensure ~/.local/bin is on PATH
    grep -qF '$HOME/.local/bin' "$shell_config" \
        || echo 'export PATH="$HOME/.local/bin:$PATH"' >>"$shell_config"
fi

echo ""
echo "Done! Run: source ~/.bashrc"

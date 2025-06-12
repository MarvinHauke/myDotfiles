#!/bin/sh

# =============================================================================
# ZSH CONFIGURATION
# =============================================================================

# source the path to zap Plugin manager
[ -f "$HOME/.local/share/zap/zap.zsh" ] && source "$HOME/.local/share/zap/zap.zsh"

# =============================================================================
# ENVIRONMENT VARIABLES
# =============================================================================

# Zsh config dir
export ZSH="$HOME/.zshrc"

# Set XDG_CONFIG_HOME path for ghostty and other cmdline tools
export XDG_CONFIG_HOME="$HOME/.config"

# Editor settings
export EDITOR=nvim
export VISUAL=nvim

# Development paths
export PATH="/opt/homebrew/opt/llvm/bin:$PATH"
export LDFLAGS="-L/opt/homebrew/opt/llvm/lib"
export CPPFLAGS="-I/opt/homebrew/opt/llvm/include"
export STM32_PRG_PATH=/Applications/STMicroelectronics/STM32Cube/STM32CubeProgrammer/STM32CubeProgrammer.app/Contents/MacOs/bin

# Node Version Manager (NVM) - not for Nvim!
export NVM_DIR="$HOME/.nvm"

# =============================================================================
# FUNCTIONS
# =============================================================================

# Load .env file if it exists
load_env() {
  if [ -f "$HOME/.env" ]; then
    export "$(grep -v '^#' "$HOME/.env" | xargs)"
    echo "✓ Loaded environment variables from ~/.env"
  else
    echo "⚠ No .env file found at ~/.env"
  fi
}

# Quick directory navigation (TODO: use this instead of cdd and cdn test it and validate)
dev() { cd "$HOME/Development/$1" 2>/dev/null || cd "$HOME/Development" }
conf() { cd "$XDG_CONFIG_HOME/$1" 2>/dev/null || cd "$XDG_CONFIG_HOME" }

# # Define the config alias ( old version use "dotfiles" command instead)
# alias config='git --git-dir=$HOME/.cfg/ --work-tree=$HOME'

# Git bare repo management for dotfiles (TODO: test it and validate if dotfiles is working better)
# The function is essentially the same functionality but with better naming and more robust argument handling. It's a small change that makes your dotfiles management much clearer and more maintainable!
dotfiles() {
  git --git-dir="$HOME/.cfg/" --work-tree="$HOME" "$@"
}

# Enhanced dotfiles lazygit wrapper
dotfiles-lg() {
    if [[ ! -d "$HOME/.cfg" ]]; then
        echo "⚠ Dotfiles bare repository not found at ~/.cfg"
        return 1
    fi
    
    echo "🚀 Opening lazygit for dotfiles management..."
    lazygit --git-dir="$HOME/.cfg/" --work-tree="$HOME"
}

# =============================================================================
# INITIALIZE ENVIRONMENT
# =============================================================================

# Call load_env function
load_env

# set Starship config path
eval "$(starship init zsh)"
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"

# =============================================================================
# ZSH PLUGINS
# =============================================================================

# Essential plugins
plug "zap-zsh/zsh-syntax-highlighting"        # adds syntax-highlighting to shell commands
plug "zap-zsh/zsh-autosuggestions"            # adds autosuggestions to shell commands
plug "zap-zsh/vim"                            # simple vi-mode for zsh https://github.com/zap-zsh/vim
plug "zsh-users/zsh-history-substring-search" # fish style substring search https://github.com/zsh-users/zsh-history-substring-search
plug "zsh-users/zsh-completions"              # https://github.com/zsh-users/zsh-completions

# Visual enhancements
plug "zsh-zsh/supercharge" # adds color to ls https://github.com/zap-zsh/supercharge
plug "wintermi/zsh-lsd"    # makes everything colorfull https://github.com/wintermi/zsh-lsd

# Productivity plugins
plug "MichaelAquilina/zsh-you-should-use" # shows aliases you should use instead
plug "kutsan/zsh-system-clipboard"        # https://github.com/kutsan/zsh-system-clipboard
plug "aloxaf/fzf-tab"                     # Use fzf for tab completion https://github.com/aloxaf/zsh-fzf-tab
plug "Freed-Wu/fzf-tab-source"            # Additional sources for fzf-tab https://github.com/Freed-Wu/fzf-tab-source

# =============================================================================
# COMPLETION SYSTEM
# =============================================================================

# Initialize completion system
autoload -U compinit && compinit

# # Completion styling (TODO: not tested, check incremantaly)
# zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # Case-insensitive
# zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"     # Colored completions
# zstyle ':completion:*' menu select                        # Menu selection
# zstyle ':completion:*' group-name ''                      # Group completions
# zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'

# zstyle ':fzf-tab:*' fzf-flags --height=50% --reverse --border
# zstyle ':fzf-tab:*' continuous-trigger 'right'

# =============================================================================
# ZSH OPTIONS (TODO: not tested, check incremantaly)
# =============================================================================

# # History settings
# HISTFILE=~/.zsh_history
# HISTSIZE=10000
# SAVEHIST=10000
# setopt SHARE_HISTORY     # Share history between sessions
# setopt HIST_IGNORE_DUPS  # Don't record duplicates
# setopt HIST_IGNORE_SPACE # Don't record commands starting with space
# setopt HIST_VERIFY       # Show command before executing from history
#
# # Completion options
# setopt COMPLETE_IN_WORD # Complete from both ends of word
# setopt AUTO_LIST        # List choices on ambiguous completion
# setopt AUTO_MENU        # Use menu completion
# setopt AUTO_PARAM_SLASH # Add slash after directory completion
#
# # Directory options
# setopt AUTO_CD           # cd by typing directory name
# setopt AUTO_PUSHD        # Push directories to stack
# setopt PUSHD_IGNORE_DUPS # Don't push duplicates

# =============================================================================
# DEPENDENCY CHECKS
# =============================================================================

# Check for important tools and provide installation hints
missing_tools=()

command -v fzf >/dev/null || missing_tools+=("fzf (brew install fzf) - https://github.com/junegunn/fzf")
command -v zoxide >/dev/null || missing_tools+=("zoxide (brew install zoxide) - https://github.com/ajeetdsouza/zoxide")
command -v starship >/dev/null || missing_tools+=("starship (brew install starship) - https://github.com/starship/starship")
command -v direnv >/dev/null || missing_tools+=("direnv (brew install direnv) - https://github.com/direnv/direnv")
command -v uv >/dev/null || missing_tools+=("uv (brew install uv) - https://github.com/astral-sh/uv")
command -v nvim >/dev/null || missing_tools+=("neovim (brew install neovim) - https://github.com/neovim/neovim")
command -v lsd >/dev/null || missing_tools+=("lsd (brew install lsd) - https://github.com/lsd-rs/lsd")
command -v tmux >/dev/null || missing_tools+=("tmux (brew install tmux) - https://github.com/tmux/tmux")

if (( ${#missing_tools[@]} > 0 )); then
    echo "⚠ Missing tools detected:"
    printf "  - %s\n" "${missing_tools[@]}"
    echo ""
fi

# =============================================================================
# EXTERNAL INTEGRATIONS
# =============================================================================

# FZF keybindings
if command -v fzf >/dev/null; then
if [ -f /opt/homebrew/opt/fzf/shell/key-bindings.zsh ]; then
        source /opt/homebrew/opt/fzf/shell/key-bindings.zsh
    else
        echo "⚠ fzf is installed but key-bindings not found at expected location"
    fi
fi

# Zoxide (smart cd)
command -v zoxide >/dev/null && eval "$(zoxide init --cmd cd zsh)"

# Direnv (local environment variables)
command -v direnv >/dev/null && eval "$(direnv hook zsh)"

# UV shell completion (Python toolchain)
command -v uv >/dev/null && eval "$(uv generate-shell-completion zsh)"

[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

# =============================================================================
# ALIASES
# =============================================================================

# Enhanced ls aliases
alias ls='lsd'                                # Use lsd instead of ls
alias ll='lsd -alF'                          # Long format with file type indicators
alias la='lsd -A'                            # Show hidden files
alias lt='lsd --tree'                        # Tree view

# Editor aliases
alias vim='nvim'
alias vi='nvim'

# Quick navigation (deprecated with zoxide, but kept for muscle memory)
alias cdd='cd $HOME/Development' # (use dev() instead)
alias cdl='cd $HOME/Downloads'
alias cdn='cd $XDG_CONFIG_HOME/nvim' # (use config() instead be carefull with)
alias cdt='cd $XDG_CONFIG_HOME/tmux'

# Config editing shortcuts
alias nvc='nvim $XDG_CONFIG_HOME/nvim/.'
alias nvt='nvim $XDG_CONFIG_HOME/tmux/tmux.conf'
alias nvz='nvim $ZSH'
alias nvs='nvim $STARSHIP_CONFIG'
alias src='source $ZSH'
alias notes='nvim $HOME/Notizen'

# System aliases
alias lsusb='cyme'
alias :q='exit'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Git shortcuts (in addition to your dotfiles function)
alias g='git'
alias gs='git status'
alias gp='git push'
alias gl='git pull'
alias gc='git commit'
alias gca='git commit -a'
alias gco='git checkout'
alias gb='git branch'

# System monitoring
alias top='htop'
alias df='df -h'
alias du='du -h'
alias free='free -h'

# File associations
alias -s pdf='zathura --fork'
alias -s {jpg,jpeg,png,gif}='open'
alias -s {mp4,mkv,avi}='open'

# Alert alias for long running commands
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# =============================================================================
# TMUX AUTO-START
# =============================================================================

# Always work in a tmux session if available
if which tmux >/dev/null 2>&1; then
  # Check if current environment is suitable for tmux
  if [[ -z "$TMUX" &&
    $TERM != "screen-256color" &&
    $TERM != "screen" &&
    -z "$VSCODE_INJECTION" &&
    -z "$INSIDE_EMACS" &&
    -z "$EMACS" &&
    -z "$VIM" &&
    -z "$INTELLIJ_ENVIRONMENT_READER" ]]; then
    # Attach to default session or create new one
    tmux attach -t default >/dev/null 2>&1 || tmux new -s default
    exit
  fi
fi

# =============================================================================
# PERFORMANCE OPTIMIZATIONS
# =============================================================================

# Lazy load NVM (uncomment if NVM is slow to load)
# nvm() {
#   unset -f nvm
#   [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
#   nvm "$@"
# }

# =============================================================================
# LOCAL CUSTOMIZATIONS
# =============================================================================

# Source local customizations if they exist
[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"

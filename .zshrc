#!/bin/zsh

# =============================================================================
# ZSH CONFIGURATION
# =============================================================================

# source the path to zap Plugin manager
[ -f "$HOME/.local/share/zap/zap.zsh" ] && source "$HOME/.local/share/zap/zap.zsh"

# =============================================================================
# ENVIRONMENT VARIABLES
# =============================================================================

# Zsh config file
export ZSHRC="$HOME/.zshrc"

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

# Github
[ -f ~/.config/github/token ] && export GITHUB_TOKEN=$(cat ~/.config/github/token)

# Node Version Manager (NVM) - not for Nvim!
export NVM_DIR="$HOME/.nvm"

# =============================================================================
# FUNCTIONS
# =============================================================================

# Load .env file if it exists
load_env() {
  if [ -f "$HOME/.env" ]; then
    set -a; source "$HOME/.env"; set +a
  fi
}

# Quick directory navigation
dev() { cd "$HOME/Development/$1" 2>/dev/null || cd "$HOME/Development" }
conf() { cd "$XDG_CONFIG_HOME/$1" 2>/dev/null || cd "$XDG_CONFIG_HOME" }

# Zathura PDF viewer (fork and detach from terminal)
zathura() { command zathura --fork "$@" >/dev/null 2>&1 }

# Git bare repo management for dotfiles
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

# Starship prompt
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
eval "$(starship init zsh)"

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
plug "zap-zsh/supercharge" # adds color to ls https://github.com/zap-zsh/supercharge
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

# Custom function to accept autosuggestion or clear screen
accept-suggestion-or-clear() {
    if [[ -n $POSTDISPLAY ]]; then
        # If there's an autosuggestion, accept it
        zle autosuggest-accept
    else
        # If no autosuggestion, clear screen
        zle clear-screen
    fi
}
# Create a widget from the function
zle -N accept-suggestion-or-clear
# Bind Ctrl+L to the custom function
bindkey '^L' accept-suggestion-or-clear


# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # Case-insensitive
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"     # Colored completions
zstyle ':completion:*' menu select                        # Menu selection
zstyle ':completion:*' group-name ''                      # Group completions
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'

zstyle ':fzf-tab:*' fzf-flags --height=50% --reverse --border
zstyle ':fzf-tab:*' continuous-trigger 'right'

# =============================================================================
# ZSH OPTIONS
# =============================================================================

# History settings
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY      # Share history between sessions
setopt HIST_IGNORE_DUPS   # Don't record duplicates
setopt HIST_FIND_NO_DUPS  # Hide duplicates when searching history
setopt HIST_IGNORE_SPACE # Don't record commands starting with space
setopt HIST_VERIFY       # Show command before executing from history

# Completion options
setopt COMPLETE_IN_WORD # Complete from both ends of word
setopt AUTO_LIST        # List choices on ambiguous completion
setopt AUTO_MENU        # Use menu completion
setopt AUTO_PARAM_SLASH # Add slash after directory completion

# Directory options
setopt AUTO_CD           # cd by typing directory name
setopt AUTO_PUSHD        # Push directories to stack
setopt PUSHD_IGNORE_DUPS # Don't push duplicates

# =============================================================================
# DEPENDENCY CHECKS
# =============================================================================

# Check for important tools (run manually with: check-deps)
check-deps() {
  local missing_tools=()

  command -v fzf >/dev/null || missing_tools+=("fzf (brew install fzf) - https://github.com/junegunn/fzf")
  command -v zoxide >/dev/null || missing_tools+=("zoxide (brew install zoxide) - https://github.com/ajeetdsouza/zoxide")
  command -v starship >/dev/null || missing_tools+=("starship (brew install starship) - https://github.com/starship/starship")
  command -v direnv >/dev/null || missing_tools+=("direnv (brew install direnv) - https://github.com/direnv/direnv")
  command -v uv >/dev/null || missing_tools+=("uv (brew install uv) - https://github.com/astral-sh/uv")
  command -v nvim >/dev/null || missing_tools+=("neovim (brew install neovim) - https://github.com/neovim/neovim")
  command -v lsd >/dev/null || missing_tools+=("lsd (brew install lsd) - https://github.com/lsd-rs/lsd")
  command -v tmux >/dev/null || missing_tools+=("tmux (brew install tmux) - https://github.com/tmux/tmux")

  if (( ${#missing_tools[@]} > 0 )); then
    echo "Missing tools detected:"
    printf "  - %s\n" "${missing_tools[@]}"
  else
    echo "All tools installed."
  fi
}

# =============================================================================
# EXTERNAL INTEGRATIONS
# =============================================================================

# FZF keybindings and completion
command -v fzf >/dev/null && eval "$(fzf --zsh)"

# Zoxide (smart cd)
command -v zoxide >/dev/null && eval "$(zoxide init --cmd cd zsh)"

# Direnv (local environment variables)
command -v direnv >/dev/null && eval "$(direnv hook zsh)"

# UV shell completion (Python toolchain)
command -v uv >/dev/null && eval "$(uv generate-shell-completion zsh)"

# NVM lazy loading (defers ~200-400ms startup cost until first use)
nvm() {
  unset -f nvm node npm npx
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
  nvm "$@"
}
node() { unset -f node; nvm use default >/dev/null; command node "$@"; }
npm() { unset -f npm; nvm use default >/dev/null; command npm "$@"; }
npx() { unset -f npx; nvm use default >/dev/null; command npx "$@"; }

# =============================================================================
# ALIASES
# =============================================================================

# Tree view (ls/ll/la/tree provided by zsh-lsd plugin)
alias lt='lsd --tree'

# Editor aliases
alias vim='nvim'
alias vi='nvim'

# Quick navigation
alias cdl='cd $HOME/Downloads'
alias cdt='cd $XDG_CONFIG_HOME/tmux'

# Config editing shortcuts
alias nvc='nvim $XDG_CONFIG_HOME/nvim/.'
alias nvt='nvim $XDG_CONFIG_HOME/tmux/tmux.conf'
alias nvz='nvim $ZSHRC'
alias nvs='nvim $STARSHIP_CONFIG'
alias src='source $ZSHRC'
alias notes='nvim $HOME/Notizen'

# System aliases
alias lsusb='cyme'
alias :q='exit'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias avrdude7="/Applications/Teensyduino.app/Contents/Java/hardware/tools/avr/bin/avrdude -C /Applications/Teensyduino.app/Contents/Java/hardware/tools/avr/etc/avrdude.conf"

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

# File associations (pdf handled by zathura function)
alias -s {jpg,jpeg,png,gif}='open'
alias -s {mp4,mkv,avi}='open'

# =============================================================================
# TMUX AUTO-START
# =============================================================================

# Always work in a tmux session if available
if command -v tmux >/dev/null 2>&1; then
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
    return
  fi
fi

# =============================================================================
# LOCAL CUSTOMIZATIONS
# =============================================================================

# Source local customizations if they exist
[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"

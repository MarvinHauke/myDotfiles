#!/bin/sh

#source the path to zap Plugin manager
[ -f "$HOME/.local/share/zap/zap.zsh" ] && source "$HOME/.local/share/zap/zap.zsh"

# zsh config dir
export ZSH="$HOME/.zshrc"

# set XDG_CONFIG_HOME path for ghostty and other cmdline tools
export XDG_CONFIG_HOME="$HOME/.config"

# set Starship config path
eval "$(starship init zsh)"
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"

# load plugins with zap
plug "zap-zsh/zsh-syntax-highlighting"        # adds syntax-highlighting to shell commands
plug "zap-zsh/zsh-autosuggestions"            # adds autosuggestions to shell commands
plug "zap-zsh/vim"                            # simple vi-mode for zsh https://github.com/zap-zsh/vim
plug "zsh-users/zsh-history-substring-search" # fish style substring search https://github.com/zsh-users/zsh-history-substring-search
plug "zsh-users/zsh-completions"              # https://github.com/zsh-users/zsh-completions
plug "zsh-zsh/supercharge"                    # adds color to ls https://github.com/zap-zsh/supercharge
plug "wintermi/zsh-lsd"                       # makes everything colorfull https://github.com/wintermi/zsh-lsd
plug "MichaelAquilina/zsh-you-should-use"     # shows aliases you should use instead
plug "kutsan/zsh-system-clipboard"            # https://github.com/kutsan/zsh-system-clipboard
plug "aloxaf/fzf-tab"                         # Use fzf for tab completion https://github.com/aloxaf/zsh-fzf-tab
plug "Freed-Wu/fzf-tab-source"                # Additional sources for fzf-tab https://github.com/Fred-Wu/fzf-tab-source

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias vim='nvim'
alias cdd='cd $HOME/Development'     # deprecated if you use zoxide
alias cdl='cd $HOME/Downloads'       # deprecated if you use zoxide
alias cdn='cd $XDG_CONFIG_HOME/nvim' # deprecated if you use zoxide
alias cdt='cd $XDG_CONFIG_HOME/tmux' # deprecated if you use zoxide
alias nvc='nvim $XDG_CONFIG_HOME/nvim/.'
alias nvt='nvim $XDG_CONFIG_HOME/tmux/tmux.conf'
alias nvz='nvim $ZSH'
alias src='source $ZSH'
alias notes='nvim $HOME/Notizen'
alias lsusb='cyme'
alias :q='exit'

# Define the config alias
alias config='git --git-dir=$HOME/.cfg/ --work-tree=$HOME'

# Add an "alert" alias for long running commands.  Use like so:
# sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Tmux
# Always work in a tmux session if Tmux is installed
if which tmux >/dev/null 2>&1; then
  # Check if the current environment is suitable for tmux
  if [[ -z "$TMUX" &&
    $TERM != "screen-256color" &&
    $TERM != "screen" &&
    -z "$VSCODE_INJECTION" &&
    -z "$INSIDE_EMACS" &&
    -z "$EMACS" &&
    -z "$VIM" &&
    -z "$INTELLIJ_ENVIRONMENT_READER" ]]; then
    # Try to attach to the default tmux session, or create a new one if it doesn't exist
    tmux attach -t default >/dev/null 2>&1 || tmux new -s default
    exit
  fi
fi

# Setup Zoxide for easy "cd anywhere"
eval "$(zoxide init --cmd cd zsh)"

# Setup for direnv local .env files
eval "$(direnv hook zsh)"

# Setup shellcompletion for uv (a python toolchain manager)
eval "$(uv generate-shel-completion zsh)"

# this is for Node-Version-Manager not for Nvim. Dont touch it!!!
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

export PATH="/opt/homebrew/opt/llvm/bin:$PATH"
export LDFLAGS="-L/opt/homebrew/opt/llvm/lib"
export CPPFLAGS="-I/opt/homebrew/opt/llvm/include"

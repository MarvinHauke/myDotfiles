#!/bin/sh

#source the path to zap Plugin manager
[ -f "$HOME/.local/share/zap/zap.zsh" ] && source "$HOME/.local/share/zap/zap.zsh"

# zsh config dir
export ZSH="$HOME/.zshrc"

# set Ghostty config path
export XDG_CONFIG_HOME="$HOME/.config"

# set Starship config path
eval "$(starship init zsh)"
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"

# load plugins with zap
plug "zap-zsh/zsh-syntax-highlighting" # adds syntax-highlighting to shell commands
plug "zap-zsh/zsh-autosuggestions"     # adds autosuggestions to shell commands
plug "zap-zsh/vim"                     # adds vim keybindings
# plug "jeffreytse/zsh-vi-mode" # adds vi mode
plug "zap-zsh/fzf" # adds fzf keybindings
plug "zsh-users/zsh-history-substring-search"
plug "zsh-users/zsh-completions"
plug "zsh-zsh/supercharge"                # adds color to ls
plug "wintermi/zsh-lsd"                   # makes everything colorfull
plug "MichaelAquilina/zsh-you-should-use" # shows aliases you should use instead
plug "kutsan/zsh-system-clipboard"

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias cdd='cd $HOME/Development'
alias cdl='cd $HOME/Downloads'
alias vim='nvim'
alias cdn='cd $XDG_CONFIG_HOME/nvim'
alias nvc='nvim $XDG_CONFIG_HOME/nvim/.'
alias src='source $ZSH'
alias nvz='nvim $ZSH'
alias notes='nvim $HOME/Notizen'
alias lsusb='cyme'
alias :q='exit'

# Define the config alias
alias config='git --git-dir=$HOME/.cfg/ --work-tree=$HOME'

# Add an "alert" alias for long running commands.  Use like so:
# sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# this is for Node-Version-Manager not for Nvim. Dont touch it!!!
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

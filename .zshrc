# set Ghostty config path
export XDG_CONFIG_HOME="$HOME/.config/"

# set Starship config path
eval "$(starship init zsh)"
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias cdd='cd $HOME/Development'
alias cdl='cd $HOME/Downloads'
alias vim='nvim'
alias cdn='cd $XDG_CONFIG_HOME/nvim'
alias src='source $HOME/.zshrc'
alias nvc='nvim $XDG_CONFIG_HOME/nvim/.'

# Add an "alert" alias for long running commands.  Use like so:
# sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Set config Alias
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'

# this is for Node-Version-Manager not for Nvim. Dont touch it!!!
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

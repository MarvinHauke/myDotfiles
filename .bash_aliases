# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias cdl='cd $HOME/Downloads'

cdd() {
  cd "$HOME/Development/${1:-}" 2>/dev/null || cd "$HOME/Development"
}

# Add an "alert" alias for long running commands.  Use like so:
# sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Git bare repo management for dotfiles
dotfiles() {
  git --git-dir="$HOME/.cfg/" --work-tree="$HOME" "$@"
}

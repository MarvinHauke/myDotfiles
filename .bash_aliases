# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias cdd= 'cd $DEV'
alias cdl='cd /mnt/c/Users/Marvi/Downloads'

# Add an "alert" alias for long running commands.  Use like so:
# sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'

# Completion for config

_completion() {
    declare -a COMMANDS=(foo bar blah)
    if [[ -n $COMP_LINE ]]; then
        for c in "${COMMANDS[@]}"; do
            [[ ${c:0:${#2}} == "${2,,}" ]] && echo "$c"
        done
        exit
    fi
    declare CMD="$1"
}

# git completion for Cnfig
# _config_completion() {
#     # Source the Git completion script
#     source /usr/share/bash-completion/completions/git

#     # Use the completions of "git" for the "config" alias
#     COMPREPLY=("${COMPREPLY[@]/#git/config}")
# }
# if [ -f /usr/share/bash-completion/completions/git ]; then
#     cp /usr/share/bash-completion/completions/git ~/.git_completion
# else
#     echo "git completion does not exist! check /usr/share/bash-completion/completions/git"
# fi

# some more ls and cd aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias cdd='cd $HOME/Development'
alias cdl='cd /mnt/c/Users/Marvi/Downloads'
alias activate='source .venv/bin/activate'

# source ~/_completion.sh
# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'

# Associate the autocompletion function with the 'config' alias
# source /usr/share/bash-completion/completions/git
# complete -C ~/.git_completion config
complete -C _completion config

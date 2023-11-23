# Completion example

_cdd_function() {
    if [ "$#" -eq 0 ]; then
        cd "$HOME"/Development || exit
    fi
}
_cdl_function() {
    if [ "$#" -eq 0 ]; then
        cd "$HOME"/Downloads || exit
    fi
}

_completion() {
    # declare -a COMMANDS=(foo bar blah)
    # path_var=$HOME/Development
    if [ "$1" == "cdd" ]; then
        local path_var="$HOME"/Development
    elif [ "$1" == "cdl" ]; then
        local path_var="$HOME"/Downloads
    fi

    ls "$path_var"

    if [[ -n $COMP_LINE ]]; then
        local cur prev words cword
        _get_comp_words_by_ref -n : cur prev words cword #This line commes from the Readline library in Bash
        # Use an ls command to populate the COMMANDS array
        # Extract the second word from the alias definition
        local alias_name=$1

        # Use alias command to get the definition of the specified alias

        # if [[ -d $1 == "cdd" ]]; then
        #     local alias_path=$1
        #     IFS=$'\n' read -ar COMMANDS < <(ls -a "$alias_path")
        # fi

        COMPREPLY=()
        local IFS=$'\n' #Preserve spaces in filenames

        # for c in "${COMMANDS[@]}"; do
        #     [[ ${c:0:${#2}} == "${2,,}" ]] && COMPREPLY+=("$c")
        # done
        for c in "${COMMANDS[@]}"; do
            [[ ${c:0:${#cur}} == "${cur}" ]] && echo "$c"
        done
        exit
    fi
    declare CMD="$1"
}

# some more ls and cd aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias cdd=_cdd_function
alias cdl=_cdl_function
alias activate='source .venv/bin/activate'

# Add an "alert" alias for long running commands.  Use like so:
# sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Add Config as Alias with gitcompletion
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
# Add completion for config Alias
source /usr/share/bash-completion/completions/git
__git_complete config __git_main

# Associate the autocompletion function with the 'cdd' and 'cdl' alias
complete -C _completion cdd
complete -C _completion cdl

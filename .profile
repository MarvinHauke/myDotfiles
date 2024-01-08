# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022
# if running bash

if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
        . "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ]; then
    PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ]; then
    PATH="$HOME/.local/bin:$PATH"
fi

# this exports my development directory for the my dotfiles and repos
if [ ! -f "$HOME/.dyn_path" ]; then
    #look for .dyn_path and set the specific paths for your system 
    echo "There is no file to your system settings yet"
    echo "Do you want to creat a pathfile containing your System Settings?"
    read -r -p "Enter 'yes' to continue:" answer

    #Convert $answer to lowercase
    #answer_to_lower=$(echo "$answer" | tr '[:upper]' '[:lower:]')
    if [ "${answer,,}" == "y" ] || [ "${answer,,}" == "yes" ]; then
        #Set Dev directory Path
        read -r -ep "Please enter your Development Folder Path: " -e dev_path
        if [ -d "$dev_path" ]; then
            echo "cdd path was set to $dev_path"
            DEV="$dev_path"
            export DEV
        else
            echo "Invalid Path $dev_path does not exist"
            exit 1
        fi 
    else
      echo "no DEV directory set"
    fi
fi 

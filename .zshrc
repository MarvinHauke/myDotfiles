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

# Brewfile used by `brew bundle` (dump --force records, no argument restores)
export HOMEBREW_BUNDLE_FILE="$HOME/.config/brew/Brewfile"

# fzf lists open below the prompt with the input on top, newest entry first.
# Inside them: Cmd+j/k move, Cmd+l takes the entry (Ghostty sends Esc j/k/l = alt-j/k/l)
export FZF_DEFAULT_OPTS="--layout=reverse --height=50% --border=top --bind=alt-j:down,alt-k:up,alt-l:accept"

# Development paths
export PATH="/opt/homebrew/opt/llvm/bin:$PATH"
export LDFLAGS="-L/opt/homebrew/opt/llvm/lib"
export CPPFLAGS="-I/opt/homebrew/opt/llvm/include"
export STM32_PRG_PATH=/Applications/STMicroelectronics/STM32Cube/STM32CubeProgrammer/STM32CubeProgrammer.app/Contents/MacOs/bin

# Node Version Manager (NVM) - not for Nvim!
export NVM_DIR="$HOME/.nvm"
export PATH="$HOME/.nvm/versions/node/v24.16.0/bin:$PATH"

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

# Zathura PDF viewer (fork and detach from terminal)
zathura() { command zathura --fork "$@" >/dev/null 2>&1 }

# Pick processes with fzf and kill them, e.g. fkill -9
fkill() { ps -axo pid,user,%cpu,%mem,comm | fzf -m --header-lines=1 | awk '{print $1}' | xargs kill "$@" }

# Search Homebrew with fzf and install the picks, e.g. fbrew ffm
fbrew() { { brew formulae; brew casks } | fzf -m --query="$1" --preview 'brew info {}' | xargs brew install }

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
# zsh-autosuggestions hides the suggestion from widgets it does not know, so this one would always
# clear the screen. On the ignore list it sees the suggestion.
ZSH_AUTOSUGGEST_IGNORE_WIDGETS+=(accept-suggestion-or-clear)
# Bind Ctrl+L to the custom function
bindkey '^L' accept-suggestion-or-clear

# Cmd+l (Ghostty sends Esc l): take the next word of the grey suggestion.
# "/" ends a word, so a suggested path is taken folder by folder.
accept-suggestion-word() {
    local WORDCHARS=${WORDCHARS//\//}
    zle .forward-word
}
zle -N accept-suggestion-word
# tells zsh-autosuggestions that this movement accepts part of the suggestion
ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS+=(accept-suggestion-word)
bindkey -M viins '^[l' accept-suggestion-word
bindkey -M vicmd '^[l' accept-suggestion-word

# Opt+Backspace (Ghostty sends Esc Backspace): delete the word before the cursor, "/" ends a word
backward-kill-path-word() {
    local WORDCHARS=${WORDCHARS//\//}
    zle .backward-kill-word
}
zle -N backward-kill-path-word
bindkey -M viins '^[^?' backward-kill-path-word


# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # Case-insensitive
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"     # Colored completions
zstyle ':completion:*' menu select                        # Menu selection
zstyle ':completion:*' insert-tab false                   # Tab on an empty line completes instead of typing a tab
zstyle ':completion:*' group-name ''                      # Group completions
zstyle ':completion:*:descriptions' format '[%d]'            # group names; fzf-tab can't show %F colors

zstyle ':fzf-tab:*' fzf-flags --height=50% --reverse --border
zstyle ':fzf-tab:*' continuous-trigger 'right'
zstyle ':fzf-tab:*' switch-group '<' '>' # show one group at a time: < and > switch
# fzf-tab ignores FZF_DEFAULT_OPTS: same keys as the history list. Cmd+j/k move, Tab or Cmd+l takes the pick.
zstyle ':fzf-tab:*' fzf-bindings 'alt-j:down' 'alt-k:up' 'alt-l:accept' 'tab:accept'

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

# Zoxide: initialized at the end of this file (see bottom)

# Direnv (local environment variables)
command -v direnv >/dev/null && eval "$(direnv hook zsh)"

# UV shell completion (Python toolchain)
command -v uv >/dev/null && eval "$(uv generate-shell-completion zsh)"


# =============================================================================
# ALIASES
# =============================================================================

# Tree view (ls/ll/la/tree provided by zsh-lsd plugin)
alias lt='lsd --tree'

# Editor aliases
alias vim='nvim'
alias vi='nvim'

# Places: a name stands for a folder. Use as ~name anywhere: `cd ~dev`, just `~dev`,
# `nvim ~conf/tmux/tmux.conf`. Tab completes below the name. The launcher (Cmd+Space) lists them too.
hash -d dl=$HOME/Downloads
hash -d dev=$HOME/Development
hash -d conf=$XDG_CONFIG_HOME
hash -d notes=$HOME/Notizen
hash -d abl="/Volumes/ExterneSSD/Ableton Projekte"

# Tab completion for `dev <folder>` (the function is defined at the top)
_dev() { _files -W "$HOME/Development" -/ }
(( $+functions[compdef] )) && compdef _dev dev

# Config editing shortcuts: nv + first letter of the tool. The launcher lists them too.
alias nvn='nvim $XDG_CONFIG_HOME/nvim/.'
alias nvt='nvim $XDG_CONFIG_HOME/tmux/tmux.conf'
alias nvz='nvim $ZSHRC'
alias nvs='nvim $STARSHIP_CONFIG'
alias nvk='nvim $XDG_CONFIG_HOME/karabiner/karabiner.json'
alias nvh='nvim $HOME/.hammerspoon/.'
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
alias df='df -h'
alias du='du -h'

# File associations (pdf handled by zathura function)
alias -s {jpg,jpeg,png,gif}='open'
alias -s {mp4,mkv,avi}='open'

# xournalpp
alias xournal="open -a Xournal++"

# Zoxide (smart cd) - init last, before the tmux block (which may return early)
command -v zoxide >/dev/null && eval "$(zoxide init --cmd cd zsh)"

# =============================================================================
# SHELL KEYS (Ghostty sends Esc + letter for Cmd keys, see ghostty/config and docs/keys.md)
# =============================================================================

# fzf history (fzf's Ctrl+R widget) where Enter runs the command and Tab (or Cmd+l) only fills the prompt.
# Enter leaves a marker file before accepting; finding it afterwards means: run.
history-fzf() {
  local marker=${TMPDIR:-/tmp}/zsh-history-run.$$
  local FZF_CTRL_R_OPTS="${FZF_CTRL_R_OPTS-} --bind=tab:accept --bind='enter:execute-silent(touch $marker)+accept'"
  rm -f $marker
  zle fzf-history-widget
  [[ -e $marker ]] && { rm -f $marker; zle accept-line }
}

# Cmd+k / Cmd+j: fzf history with the typed text as query.
# Without fzf: older / newer command that contains the typed text.
history-older() {
  if (( $+widgets[fzf-history-widget] )); then history-fzf
  else zle history-substring-search-up; fi
}
history-newer() {
  if (( $+widgets[fzf-history-widget] )); then history-fzf
  else zle history-substring-search-down; fi
}

# Runs `cd <dir>` as if typed, so the prompt redraws and the cd lands in the history
cd-as-typed() {
  [[ -n $1 ]] || { zle reset-prompt; return }
  BUFFER="cd ${(q)1}"
  zle accept-line
}

# Cmd+Shift+k: jump to a folder visited before (zoxide list in fzf)
folder-jump() {
  (( $+commands[zoxide] && $+commands[fzf] )) || return
  cd-as-typed "$(zoxide query -i -- $LBUFFER)"
}

# Cmd+Shift+j: dive into a folder below the current one
folder-dive() {
  (( $+commands[fd] && $+commands[fzf] )) || return
  cd-as-typed "$(fd --type d --hidden --exclude .git | fzf --query="$LBUFFER" --preview 'lsd --tree --depth=1 {}')"
}

# Key help panel (Hammerspoon). `help` or `?` shows the Shell keys, `help finder` another heading of docs/keys.md.
# Space in normal mode (after Esc) opens it too, like which-key in nvim.
help() { open -g "hammerspoon://help?topic=${${*:-Shell}// /%20}" }
alias '?'=help
key-help() { help }

# Tab: take the whole grey suggestion when one is shown and the cursor is at the end,
# otherwise complete (fzf's ** trigger, which hands everything else to fzf-tab).
# Cmd+Shift+l (Ghostty sends Esc L): always complete, also while a suggestion is shown.
complete-word-fzf() {
  if (( $+widgets[fzf-completion] )); then zle fzf-completion
  elif (( $+widgets[fzf-tab-complete] )); then zle fzf-tab-complete
  else zle expand-or-complete; fi
}
tab-accept-or-complete() {
  if [[ -n $POSTDISPLAY && $CURSOR -eq ${#BUFFER} ]]; then zle autosuggest-accept
  else complete-word-fzf; fi
}
# like accept-suggestion-or-clear: only on this list does the widget see the suggestion
ZSH_AUTOSUGGEST_IGNORE_WIDGETS+=(tab-accept-or-complete)
zle -N complete-word-fzf
zle -N tab-accept-or-complete
bindkey -M viins '^I' tab-accept-or-complete
for keymap in viins vicmd; do bindkey -M $keymap '^[L' complete-word-fzf; done

zle -N history-fzf
zle -N history-older
zle -N history-newer
zle -N folder-jump
zle -N folder-dive
zle -N key-help
for keymap in viins vicmd; do
  bindkey -M $keymap '^[k' history-older
  bindkey -M $keymap '^[j' history-newer
  bindkey -M $keymap '^[K' folder-jump
  bindkey -M $keymap '^[J' folder-dive
done
bindkey -M vicmd ' ' key-help
# Ctrl+R: same history list as Cmd+k (Enter runs, Tab fills), replacing fzf's own Ctrl+R
if (( $+widgets[fzf-history-widget] )); then
  for keymap in emacs viins vicmd; do bindkey -M $keymap '^R' history-fzf; done
fi

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

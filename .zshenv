# Read by every zsh, also by scripts and by apps that start a shell. Keep it small and silent.

# Rust tools (rustup); skipped on machines without it
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# Completions installed by Homebrew packages (added by argcomplete)
fpath=(/opt/homebrew/share/zsh/site-functions "${fpath[@]}")

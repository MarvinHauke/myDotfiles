# Shell (zsh)

Config: `~/.zshenv`, `~/.zprofile`, `~/.zshrc`. Keys are listed in `keys.md` under Shell.

## Load order

| File | Read by | Holds |
|---|---|---|
| `~/.zshenv` | every zsh, also scripts | cargo env, Homebrew completions in `fpath`. Keep small and silent |
| `~/.zprofile` | login shells | `brew shellenv` |
| `~/.zshrc` | interactive shells | everything else, in the sections below |
| `~/.zshrc.local` | end of `.zshrc`, if present | machine-only settings and secrets, not tracked |
| `~/.env` | `load_env` in `.zshrc` | exported variables, not tracked |

`.zshrc` sections, top to bottom: environment, functions, starship, zap plugins, completion and
suggestion keys, options, `check-deps`, fzf / direnv / uv, aliases and places, zoxide, shell keys, tmux auto-start.
The tmux block returns early when it attaches, so anything that must run in every shell goes above it.

## Plugins (zap)

| Plugin | Does |
|---|---|
| zsh-syntax-highlighting | colors the command line |
| zsh-autosuggestions | grey suggestion from history, taken with Cmd+l / Cmd+Shift+l |
| zap-zsh/vim | vi mode; Esc switches to normal mode |
| zsh-history-substring-search | Cmd+k / Cmd+j fallback when fzf is missing |
| zsh-completions | extra completion definitions |
| supercharge, zsh-lsd | colors, `ls`/`ll`/`la`/`tree` via lsd |
| zsh-you-should-use | reminds of existing aliases |
| zsh-system-clipboard | vi yanks go to the macOS clipboard |
| fzf-tab, fzf-tab-source | Tab completion in fzf, with previews |

Update: `zap update`. Startup time: `time zsh -i -c exit` (0.12 s at last check).

## Shell keys and widgets

Ghostty turns Cmd keys into Esc + letter (`ghostty/config`), `.zshrc` binds those in insert and normal mode.

| Widget | Key | Does |
|---|---|---|
| `accept-suggestion-word` | Cmd+l | next word of the suggestion, `/` ends a word |
| `history-older` / `history-newer` | Cmd+k / Cmd+j | fzf history with the typed text as query: Enter runs the command, Tab or Cmd+l only fills the prompt (`history-fzf`). Without fzf: substring search |
| `folder-jump` | Cmd+Shift+k | `zoxide query -i`, then `cd` as if typed (prompt redraws, lands in history) |
| `folder-dive` | Cmd+Shift+j | `fd --type d` below the current folder in fzf, then `cd` |
| `key-help` | Space in normal mode | `hammerspoon://help?topic=Shell` |
| `accept-suggestion-or-clear` | Ctrl+l | take the suggestion, or clear the screen without one |

`FZF_DEFAULT_OPTS` sets the layout for every fzf list (input on top, list below it, half the screen high) and
binds alt-j / alt-k / alt-l, so Cmd+j/k/l move and accept. In history the newest command is at the top.
fzf's own keys from `fzf --zsh`: Ctrl+R history, Ctrl+T files. Its Alt+C can't be typed (Option is not Alt), Cmd+Shift+k replaces it.

## Places, functions, aliases

- Places: `hash -d` names (`~dev`, `~conf`, `~dl`, `~notes`, `~abl`), usable in any path. The launcher lists them too.
- `cd` is zoxide (`zoxide init --cmd cd`): `cd foo` jumps to the most used folder matching foo, `cdi` picks in fzf.
- Functions: `dev [folder]`, `fkill` (pick processes), `fbrew` (search and install), `dotfiles`, `dotfiles-lg`, `check-deps`.
- Config aliases: `nv` + first letter (`nvz`, `nvt`, `nvn`, `nvk`, `nvh`, `nvs`), `src` reloads `.zshrc`.

## History

`~/.zsh_history`, 50 000 entries, shared between sessions, duplicates hidden in search.
A command starting with a space is not recorded (`HIST_IGNORE_SPACE`).

## Prompt

starship, `starship/starship.toml`: folder and prompt character on the left, everything else on the right.

## Known noise

zoxide prints "detected a possible configuration issue" in shells that don't reach the end of `.zshrc`
(tmux block returns early). Harmless; `_ZO_DOCTOR=0` silences it.

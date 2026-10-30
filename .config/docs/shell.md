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
| zsh-autosuggestions | grey suggestion from history, taken with Tab (all), Cmd+l (word by word) or Right arrow |
| zap-zsh/vim | vi mode; Esc switches to normal mode |
| zsh-history-substring-search | Cmd+k / Cmd+j fallback when fzf is missing |
| zsh-completions | extra completion definitions |
| supercharge, zsh-lsd | colors, `ls`/`ll`/`la`/`tree` via lsd |
| zsh-you-should-use | reminds of existing aliases |
| zsh-system-clipboard | vi yanks go to the macOS clipboard |
| fzf-tab, fzf-tab-source | Tab completion in fzf, with previews for files and folders. Opens with Tab when no suggestion is shown, with Cmd+Shift+l always. Cmd+j/k move, Tab or Cmd+l takes the pick (`fzf-bindings`; fzf-tab ignores `FZF_DEFAULT_OPTS`). `<` / `>` switch between groups (commands, functions, ...). Group names use the plain `[%d]` format: fzf-tab prints `%F` color codes as text |

Update: `zap update`. Startup time: `time zsh -i -c exit` (0.12 s at last check).

## Shell keys and widgets

Ghostty turns Cmd keys into Esc + letter (`ghostty/config`), `.zshrc` binds those in insert and normal mode.

| Widget | Key | Does |
|---|---|---|
| `tab-accept-or-complete` | Tab | a word that looks like a path (contains `/`, starts with `~` or `.`), or an empty word after a space (`cd `), always completes in fzf. Other words: whole suggestion when one is shown and the cursor is at the end, else completion; also on an empty line (`insert-tab false`) |
| `complete-word-fzf` | Cmd+Shift+l | completion (fzf's `**` trigger, then fzf-tab), also while a suggestion is shown |
| `accept-suggestion-word` | Cmd+l | next word of the suggestion, `/` ends a word |
| `backward-kill-path-word` | Opt+Backspace | delete the word before the cursor, `/` ends a word |
| `history-older` / `history-newer` | Cmd+k / Cmd+j | fzf history with the typed text as query: Enter runs the command, Tab or Cmd+l only fills the prompt (`history-fzf`). Without fzf: substring search |
| `folder-jump` | Cmd+Shift+k | `zoxide query -i`, then `cd` as if typed (prompt redraws, lands in history) |
| `folder-dive` | Cmd+Shift+j | `fd --type d` below the current folder in fzf, then `cd` |
| `key-help` | Space in normal mode | runs `help`: `hammerspoon://help?topic=Shell`. `help <topic>` or `?` from the prompt |
| `accept-suggestion-or-clear` | Ctrl+l | take the suggestion, or clear the screen without one |

`FZF_DEFAULT_OPTS` sets the layout for every fzf list (input on top, list below it, half the screen high) and
binds alt-j / alt-k / alt-l, so Cmd+j/k/l move and accept. In history the newest command is at the top.
Ctrl+R opens the same history list (`history-fzf`). Only history lists run on Enter: in Ctrl+T, `fkill` and `fbrew`
Enter takes the pick and Tab marks several entries.
fzf's own keys from `fzf --zsh`: Ctrl+T files. Its Alt+C can't be typed (Option is not Alt), Cmd+Shift+k replaces it.

## cd completion

`cd` is zoxide. Tab after `cd ` lists the folders here; `cd src` + Tab completes local folders first.
When no local folder matches, `_cd_or_visited` offers the folders zoxide knows that match the text:
`cd .config` + Tab in a project without `.config` offers `~/.config`.
`cd foo` + Space + Tab opens zoxide's own interactive list (best matches anywhere, runs the cd).

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
The arrow is always `❯`: green, red after a failed command. The cursor shows the vi mode (block = normal,
bar = insert, set by the zap vim plugin). Starship's own mode arrow (`❮`) is off: the vim plugin replaces
`zle-keymap-select`, the hook starship redraws it from, so it only changed now and then.

## Known noise

zoxide prints "detected a possible configuration issue" in shells that don't reach the end of `.zshrc`
(tmux block returns early). Harmless; `_ZO_DOCTOR=0` silences it.

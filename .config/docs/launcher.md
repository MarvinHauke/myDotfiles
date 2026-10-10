# Launcher and opening files

Opened with Cmd+Space (`hammerspoon://launcher`).

| Input | Rows | Enter | Cmd+Enter |
|---|---|---|---|
| text | apps, places and nv aliases from `.zshrc`, opened before, recent folders and files, ordered as below; then up to 10 matches from the whole file tree | app: open. file or folder: `edit` | file or folder: show in Finder |
| `/` + text | file tree only: every file and folder below `~` and on external drives (7 levels deep) | `edit` | show in Finder |
| `=` + expression | calculator | copies the result | |

Order of the rows for a typed text (`launcher.lua`, `launcher/usage.lua`):

| Rank | Rows | Order inside |
|---|---|---|
| 1 | the row you picked last time for exactly this text | |
| 2 | name starts with the text | by use, then apps, places, folders, files |
| 3 | a word in the name starts with it, or the name contains it | same |
| 4 | only the path contains it, or scattered letters (apps) | same |
| 5 | file tree, from 3 typed characters on | as fzf ranks them |

- Every Enter and Cmd+Enter is counted for the row it opened. Use = opens weighted by age: last day 4x,
  last week 2x, last month 1x, older 0.5x.
- Rank 1 is learned per typed text: type `tr`, pick Traktor, and `tr` gives Traktor first from then on.
- Rows that were never opened keep the limit of 8 per list; opened ones are always shown when they match.
- Empty input: the most used rows of any kind first, then the remaining apps by name.
- Stored in Hammerspoon's settings under `launcher.usage` (500 entries at most). Reset:
  `hs -c 'hs.settings.clear("launcher.usage")'`, then reload Hammerspoon.
- Tab completes the highlighted app name. On a folder row it writes `/<folder>/` into the input, so you
  search below that folder.

Where the rows come from:

- Apps are found up to three folders below the app folders; the folder name is searched too
  (`traktor pro` finds "Traktor" in "Traktor Pro 3").
- Places and aliases: read from zsh itself every five minutes, so `.zshrc` is the only list. Places are the
  named directories (`hash -d dev=...`), aliases are those of the form `alias nvz='nvim <path>'`. Only the name
  is matched. Enter on a place opens a shell there, on an alias nvim.
- Opened before: files and folders you opened through the launcher, taken from the usage table. Entries on a
  drive that is not plugged in are hidden.
- File tree rows in the plain list appear from 3 typed characters on, a moment after the other rows.
- Recent files: nvim's own list (`v:oldfiles`), so text and code files only. No extra log.
- Recent folders: zoxide's list (`zoxide query -l`), already ranked by use. `Development/.../` paths come from here.
- `/` search: `fd` lists, `fzf --filter` ranks. fzf is the matching engine without its terminal window, so the
  launcher matches like `fzf` in the shell: `/dev cmd src` finds `Development/.../cmdAbl/src`.
  Left out: `~/Library`, `node_modules`, app bundles, hidden files and whatever `.gitignore` excludes.
- External drives: every drive under `/Volumes` is searched too; its rows show the full path.
- The file list is written once each time the launcher opens (`~/.cache/launcher-paths`), so a file created
  a moment ago shows up the next time you open it.
- `hammerspoon://launcher?q=/` opens the launcher directly in the file search (not on a key yet).

## Code

| File (`~/.hammerspoon/`) | Holds |
|---|---|
| `launcher.lua` | the picker: keys (Tab, Cmd+Enter), which source is asked for which input, joining the rows |
| `launcher/apps.lua` | app scan, match scoring |
| `launcher/usage.lua` | what was opened how often, what was picked for which text |
| `launcher/paths.lua` | places and aliases, opened paths, recent folders and files, drives, cached file tree and its fzf search, opening with `edit` |
| `launcher/calc.lua` | calculator; the place for sub-calculators |

A new kind of result is a new file in `launcher/` with `rows(query)` and `open(row)`, plus one branch in `launcher.lua`.

## edit: one script opens everything

    ~/.local/bin/edit [-n] [-e] [-w] <file|folder>...

Used by the shell, by Finder (key `e`) and by the launcher. First match wins:

| Situation | Result |
|---|---|
| file, and an nvim is running in the same project | the file opens there as a vertical split (or the cursor jumps to it if it is already visible) |
| folder, and a tmux pane already sits in it | a menu: go to that pane or open a new window |
| otherwise | new window in the tmux session on screen, named after the folder; for a file, nvim runs in it |
| tmux is not running | window in the session `default`, the one Ghostty attaches to |

| Flag | Effect |
|---|---|
| `-n` | open in the background: no switch to the new place, Ghostty stays where it is |
| `-e` | start nvim in a folder too (used for the nv aliases that point to a folder) |
| `-w` | always a new window for a folder, no menu |

Without `-n`, tmux switches to that place and Ghostty comes to the front.
`edit` only adds: it never creates a second session and never closes anything. The tmux status bar shows
`[default +1]` when another session is running (prefix + `s` lists them).

- Same project = same git repository. Outside a repository: the nvim or pane sits in a folder above the file.
- A folder instead of a file gives a shell in that folder (new window). The folder is also added to zoxide,
  so `z <name>` finds it in the shell.
- The menu: shown when a pane sits in exactly that folder (any session, not the pane `edit` was typed in).
  It lists those panes and "New window". Enter takes the first pane, `1`-`9` pick one, `n` opens a new
  window, Escape does nothing. With `-e` only panes that run nvim there count.
  No menu with `-w`, with `-n`, or with several targets. `edit` waits until you have chosen.
- Only plain text goes to nvim, decided by the file's content. Word, Excel, PDFs and images open in their own app.
- Text types that should still use their own app: the list `default_app` at the top of the script (now empty).
- CSV files open in nvim; up to 5000 lines the table view (csvview.nvim) switches on by itself, longer files
  stay plain text until `:CsvViewToggle` (`nvim/lua/plugins/csvview.lua`).
- An nvim that is in insert mode is put back into normal mode first.

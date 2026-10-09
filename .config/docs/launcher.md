# Launcher and opening files

Status: apps, Tab completion and `=` calculator are implemented (`~/.hammerspoon/launcher.lua`).
Everything below "Proposal" is not built yet.

## Today

| Input | Result |
|---|---|
| text | apps, ranked by match and by how often you start them; Tab completes, Enter opens |
| `=` + expression | calculator, Enter copies the result |

## Proposal: files and folders

One script does the opening, every caller uses it:

    ~/.local/bin/edit <file>     tmux session named after the file's project folder
                                 (git root, else the parent folder), nvim on the file, Ghostty to front.
                                 An existing session gets a new window instead.

| Caller | How |
|---|---|
| Shell | `edit path/to/file` |
| Finder | key `e` on the selected file (Karabiner rule, only while browsing) > `hammerspoon://edit` > `edit` |
| Launcher | Enter on a file row |

Launcher rows, apps always first:

| Input | Rows | Enter | Cmd+Enter |
|---|---|---|---|
| text | apps, then recent files and folders that match | app: open. file: `edit`. folder: Ghostty | file or folder: show in Finder |
| `/` + text | files and folders only, searched below `~` | same | same |

- Recent files: nvim's own list (`oldfiles`), so text and code files only. No extra log needed.
- Recent folders: zoxide's list (`zoxide query -l`), already ranked by use. `Development/.../` paths come from here.
- `/` search: `fd` lists, `fzf --filter` ranks. fzf is the matching engine without its terminal window, so the
  launcher matches exactly like `fzf` in the shell.
- Folder in Ghostty: new tmux session in that folder (same naming as `edit`).
- Only text and code files go to nvim. Everything else (PDF, images) opens with its normal app.

Open questions: the Finder key (`e` proposed), the prefix (`/` proposed).

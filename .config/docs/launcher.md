# Launcher and opening files

Opened with Cmd+Space (`hammerspoon://launcher`, code in `~/.hammerspoon/launcher.lua`).

| Input | Rows | Enter | Cmd+Enter |
|---|---|---|---|
| text | apps first, then recent folders, then recent files (8 each at most) | app: open. file or folder: `edit` | file or folder: show in Finder |
| `/` + text | every file and folder below `~` and on external drives (7 levels deep) | `edit` | show in Finder |
| `=` + expression | calculator | copies the result | |

- Tab completes the highlighted app name. On a folder row it writes `/<folder>/` into the input, so you
  search below that folder.
- Order inside folders and files: name starts with the text, then name contains it, then only the path contains it.
  `Develop` shows `~/Development` first.
- Recent files: nvim's own list (`v:oldfiles`), so text and code files only. No extra log.
- Recent folders: zoxide's list (`zoxide query -l`), already ranked by use. `Development/.../` paths come from here.
- `/` search: `fd` lists, `fzf --filter` ranks. fzf is the matching engine without its terminal window, so the
  launcher matches like `fzf` in the shell: `/dev cmd src` finds `Development/.../cmdAbl/src`.
  Left out: `~/Library`, `node_modules`, app bundles, hidden files and whatever `.gitignore` excludes.
- External drives: every drive under `/Volumes` is searched too; its rows show the full path.
- The file list is written once each time the launcher opens (`~/.cache/launcher-paths`), so a file created
  a moment ago shows up the next time you open it.
- `hammerspoon://launcher?q=/` opens the launcher directly in the file search (not on a key yet).

## edit: one script opens everything

    ~/.local/bin/edit [-n] <file|folder>...

Used by the shell, by Finder (key `e`) and by the launcher. First match wins:

| Situation | Result |
|---|---|
| an nvim is running in the same project | the file opens there as a vertical split (or the cursor jumps to it if it is already visible) |
| otherwise | new window in the tmux session on screen, named after the folder; for a file, nvim runs in it |
| tmux is not running | window in the session `default`, the one Ghostty attaches to |

Then tmux switches to that place and Ghostty comes to the front. `-n` skips this and opens in the background.
`edit` only adds: it never creates a second session and never closes anything. The tmux status bar shows
`[default +1]` when another session is running (prefix + `s` lists them).

- Same project = same git repository. Outside a repository: the nvim or pane sits in a folder above the file.
- A folder instead of a file gives a shell in that folder (new window).
- Only plain text goes to nvim, decided by the file's content. Word, Excel, PDFs and images open in their own app.
- Text types that should still use their own app: the list `default_app` at the top of the script (now empty).
- CSV files open in nvim; up to 5000 lines the table view (csvview.nvim) switches on by itself, longer files
  stay plain text until `:CsvViewToggle` (`nvim/lua/plugins/csvview.lua`).
- An nvim that is in insert mode is put back into normal mode first.

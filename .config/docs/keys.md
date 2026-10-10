# Keys

All hotkeys live in Karabiner: `~/.config/karabiner/karabiner.json`, in one place only
(profile > complex_modifications > rules). Tools only expose commands or URLs
(`open -g 'hammerspoon://<action>'`, bound in `~/.hammerspoon/init.lua`).
Exception: a key that only exists inside one app may live in that app's config (Ghostty, see Shell).
Everything here is implemented.

## Layers

| Layer | Modifier | Used for |
|---|---|---|
| App | Cmd, Cmd+Shift | left to the apps, never overridden (Cmd+Space is the one exception: launcher) |
| Text | Caps held = Ctrl, tapped = Esc; Ctrl+hjkl = arrows (not in Ghostty: there tmux and nvim use them) | editing, vim, tmux |
| Window | Opt+Shift | placing the focused window |
| OS | Hyper (right Cmd held = Ctrl+Opt+Cmd+Shift) | clipboard, reload, app name |
| Finder | single letters, only while browsing files | vim-style file handling |

## Window layer (Opt+Shift)

| Key | Action | Backend |
|---|---|---|
| Opt+Shift+h / l | left / right half | `hammerspoon://win?pos=left` / `right` |
| Opt+Shift+k / j | top / bottom half | `hammerspoon://win?pos=top` / `bottom` |
| Opt+Shift+z / o | upper left / upper right quarter | `hammerspoon://win?pos=topleft` / `topright` |
| Opt+Shift+n / . | lower left / lower right quarter | `hammerspoon://win?pos=bottomleft` / `bottomright` |
| Opt+Shift+m | cycle: maximized > centered 2/3 > centered 1/2 > maximized (full height) | `hammerspoon://win?pos=cycle` |
| Opt+h (tap) | move the window to the next screen, wraps around | `hammerspoon://win?pos=screen` |

The corner keys sit around h j k l on the keyboard: z and o in the row above, n and . in the row below.
Hold Opt+h still types `ª` (same tap/hold rule as Opt+m below). Opt+l is not used: it is `@`.

## Focus toggle (Opt+m)

Opt+m always means: focus this one thing, press again to put it back where it was.

| Where | Tap Opt+m | Backend |
|---|---|---|
| Ghostty | tmux: zoom the current pane / unzoom | Karabiner sends `Ctrl+Space`, `m` (existing `bind m resize-pane -Z`) |
| Everywhere else | maximize the window / restore its previous frame | `hammerspoon://win?pos=focus` |

Hold Opt+m (about 250 ms) still types `µ`, in every app. Karabiner: `to_if_alone` = focus toggle,
`to_if_held_down` = `µ`, both thresholds set to the same value. The toggle fires on key release.

## Finder

Vim-style keys, only in Finder. Code: `~/.hammerspoon/finder.lua` (what is focused, search exits, `e`)
and `~/.hammerspoon/finder/add.lua` (`a`).

| Key | Action | Sent to Finder |
|---|---|---|
| Y (Shift+y) | copy the path of the selected files | Opt+Cmd+C ("Copy as Pathname") |
| G (Shift+g) | jump to the last file | Opt+Down |
| gg | jump to the first file | Opt+Up |
| Cmd+r | rename the selected file or folder | Return (Finder's own rename key) |
| e | open the selected file in nvim, a folder in Ghostty | `hammerspoon://edit` runs `~/.local/bin/edit`, see `launcher.md` |
| a | add here: asks for a name, `name` makes a file, `name/` a folder, `dir/name` both | `hammerspoon://add` runs `finder/add.lua` |
| ? | show this table as a panel, any key closes it | `hammerspoon://help?topic=Finder` |
| Ctrl+h in the leftmost column | go up to the parent folder (in other columns Ctrl+h stays Left) | Cmd+Up ("Enclosing Folder") |
| Ctrl+j in the search field | jump to the search results and select the first one | Tab, Down |
| Escape twice in the search results | leave the search and return to the folder | Go > Back, done by `finder.lua` (no Karabiner rule) |
| Escape in an empty search field | leave the search and return to the folder | Go > Back, done by `finder.lua` (no Karabiner rule) |

How the keys know where you are:
- `finder.lua` watches Finder's focus and sets two Karabiner variables.
  `finder_editing`: 0 = browsing files, 1 = text field (rename, "Go to folder"), 2 = search field.
  `finder_first_column`: 1 while the leftmost column of the column view has the focus.
- Y, G, gg, Cmd+r, e, a and ? only fire on `finder_editing` 0, so the letters type normally in text fields.
- Ctrl+h sends Cmd+Up only on `finder_first_column` 1; everywhere else the general Ctrl+hjkl rule sends Left.
- The variables are handed to Karabiner one call after the other; sent in parallel, an older value can
  arrive last and the search field then counts as "browsing".

Per key:
- `?` reads the table above from this file (`help.lua`): edit a row here and the panel changes with it. Any
  `## heading` with a table works as a topic, for example `hammerspoon://help?topic=OS layer`.
- `e`: files that are not plain text open in their own app.
- `a` creates next to the selected item (the column you are in); in a column without a selection (an empty
  folder), in that folder. The row under the input says what Enter will create, or why not. Nothing is
  overwritten. At "Computer" there is no folder, a notice appears instead.
  Finder creates the item itself and it is then selected in the same column, about 0.3 to 1 s later (Finder
  needs that long to show it). Not done with Finder's "reveal": that opens a second window.
  Finder's own Cmd+Shift+N (new folder) is unchanged.
- `e` and `a` take type-to-select for names starting with e and a.
- G and gg work in list and column view, not in icon view (Finder ignores Opt+Up/Down there).
- `gg`: the first `g` is held back for 250 ms. A single `g` (type-to-select) is therefore slow, and quickly
  typing `g` plus another letter loses the `g`. To get the old behaviour back (first `g` sent at once, selection
  flashes to a g-file on `gg`): in the rule, set `to` of the last `g` manipulator to `[g, finder_g=1]` and
  remove the `g` from `to_if_invoked`.
- Cmd+r replaces Finder's "Show Original" (for aliases) on that key.

Search:
- When focus leaves an empty search field, `finder.lua` sends Go > Back. It reacts to the focus change, so it
  works for the Escape key and for Caps Lock tapped as Escape. With text in the field the first Escape clears
  it, the second one leaves.
- Escape twice (within 0.5 s) is watched by Hammerspoon itself, only while Finder is in front. This is the one
  key not defined in Karabiner: Karabiner rules never see the Escape that a Caps Lock tap produces.
- Both rely on English Finder texts (window title "Searching ...", menu "Go > Back").

Karabiner key names follow the US layout: the key labelled Y on the German keyboard is `z` in the rule,
`?` is Shift+`hyphen`.

## Ableton Live

| Key | Action | Sent to Live |
|---|---|---|
| : | open the cmdAbl command palette | rule shipped by the cmdAbl extension (`assets/complex_modifications/cmdabl.json`) |
| Ctrl+Minus | show or hide the browser | Cmd+Opt+5 |

## Shell (Ghostty + zsh)

The grey text after the cursor is a suggestion from your history (zsh-autosuggestions).

| Key | Action | How |
|---|---|---|
| Cmd+l | take the next word of the suggestion; `/` ends a word, so paths go folder by folder | Ghostty sends Esc l, `.zshrc` binds `accept-suggestion-word` |
| Cmd+Shift+l | take the whole suggestion | Ghostty sends Esc L, `.zshrc` binds `autosuggest-accept` |
| Ctrl+Shift+l | clear the screen | |
| Right arrow | take the whole suggestion | plugin default |
| Tab | completion picker (fzf-tab), a different thing from the grey text | |

Places and config shortcuts, defined in `.zshrc` and also listed by the launcher:

| Type | Names | Use |
|---|---|---|
| place | `~dev`, `~conf`, `~dl`, `~notes`, `~abl` | `cd ~dev`, just `~dev`, `nvim ~conf/tmux/tmux.conf`; Tab completes below |
| function | `dev [folder]` | jump to `~/Development[/folder]`, with Tab completion |
| nvim alias | `nvz` zsh, `nvt` tmux, `nvs` starship, `nvn` nvim, `nvk` Karabiner, `nvh` Hammerspoon, `notes` | open that config in nvim |

- A terminal never sees Cmd, so the two `keybind` lines in `ghostty/config` translate the keys.
- Caps+l (Ctrl+l) is not available for this: inside tmux it switches panes.
- Pressing Escape and `l` by hand within 0.25 s (`KEYTIMEOUT=25`) counts as Cmd+l.

## OS layer (Hyper)

| Key | Action | Backend |
|---|---|---|
| Cmd+Space | launcher: apps, places, files and folders, most used first; `/` searches all files, `=` calculates; Tab completes, Cmd+Enter shows in Finder | `hammerspoon://launcher`, see `launcher.md` |
| Hyper+v | clipboard history | `hammerspoon://clipboard` |
| Hyper+r | reload Hammerspoon | `hammerspoon://reload` |
| Hyper+i | show the name of the front app | `hammerspoon://appname` |

Free for later: Hyper+1..9. Avoid Opt+Shift+number, Option+number types `[ ] | { }` on the German layout.
Fixed desktops were considered and dropped (2026-10): AltTab, tmux windows and the launcher cover switching.

## Capture

The built-in macOS keys, unchanged: Cmd+Shift+3 (screen), Cmd+Shift+4 (selection), Cmd+Shift+5 (toolbar, recording).
Files go to `/tmp/shots` and the path lands on the clipboard. Add Ctrl for the image on the clipboard instead.
These are macOS system keys, not Karabiner rules. Details in `capture.md`.

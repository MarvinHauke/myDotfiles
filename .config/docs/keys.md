# Keys

All hotkeys live in Karabiner (`~/.config/karabiner/`). Tools only expose commands or URLs.
Status: layers, window, focus and OS keys are implemented (desktops and capture are still proposals).
Rules live in `karabiner.json`; `assets/complex_modifications/hammerspoon.json` is the same set as a catalog.

## Layers

| Layer | Modifier | Used for |
|---|---|---|
| App | Cmd, Cmd+Shift | left to the apps, never overridden (except capture, see below) |
| Text | Caps held = Ctrl, tapped = Esc; Ctrl+hjkl = arrows | editing, vim, tmux (exists) |
| Window | Opt+Shift | placing the focused window (same keys as today in Raycast) |
| OS | Hyper (right Cmd held = Ctrl+Opt+Cmd+Shift) | desktops, clipboard, reload |

## Window layer (Opt+Shift)

| Key | Action | Backend |
|---|---|---|
| Opt+Shift+h / l | left / right half | `hammerspoon://win?pos=left` / `right` |
| Opt+Shift+k / j | top / bottom half | `hammerspoon://win?pos=top` / `bottom` |
| Opt+Shift+m | cycle: maximized > centered 2/3 > centered 1/2 > maximized (full height) | `hammerspoon://win?pos=cycle` |
| Opt+h (tap) | move the window to the next screen, wraps around | `hammerspoon://win?pos=screen` |

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

Vim-style keys, only in Finder and only while browsing files.

| Key | Action | Sent to Finder |
|---|---|---|
| Y (Shift+y) | copy the path of the selected files | Opt+Cmd+C ("Copy as Pathname") |
| G (Shift+g) | jump to the last file | Opt+Down |
| gg | jump to the first file | Opt+Up |
| Cmd+r | rename the selected file or folder | Return (Finder's own rename key) |

- While renaming or typing in a search field the keys type normally. Hammerspoon (`finder.lua`) watches
  Finder's focus and sets the Karabiner variable `finder_editing`; the rules check it.
- G and gg work in list and column view, not in icon view (Finder ignores Opt+Up/Down there).
- Known side effect of `gg`: the first `g` goes to Finder at once, so Finder's type-to-select runs. A single `g`
  selects the first file starting with g (or the nearest one), and `gg` shows that selection briefly before it
  lands on the first file.
  Possible change: hold the first `g` back for 250 ms. Then `gg` is clean, but a single `g` is slow and quickly
  typing `g` plus another letter loses the `g`.
- Cmd+r replaces Finder's "Show Original" (for aliases) on that key.
- Karabiner key names follow the US layout: the key labelled Y on the German keyboard is `z` in the rule.

## OS layer (Hyper)

| Key | Action | Backend |
|---|---|---|
| Cmd+Space | launcher; Tab completes the highlighted name; type `=` first to calculate, Enter copies the result | `hammerspoon://launcher` |
| Hyper+1..6 | go to desktop N (proposal) | see `desktops.md` |
| Hyper+Shift+1..6 | move window to desktop N (proposal) | see `desktops.md` |
| Hyper+v | clipboard history | `hammerspoon://clipboard` |
| Hyper+r | reload Hammerspoon | `hammerspoon://reload` |
| Hyper+i | show the name of the front app | `hammerspoon://appname` |

Desktops are not on Opt+Shift+number, because Option+number types `[ ] | { }` on the German layout.

## Capture (keeps the macOS numbers)

Number = what, modifier = where.

| Key | What | Where |
|---|---|---|
| Cmd+Shift+3 | full screen | clipboard |
| Cmd+Shift+4 | selection | clipboard |
| Cmd+Shift+5 | record selection | `/tmp/shots/*.mov` |
| add Opt to 3 or 4 | same | file in `/tmp/shots/*.png` |

Details in `capture.md`.

# Keys

All hotkeys live in Karabiner (`~/.config/karabiner/`). Tools only expose commands or URLs.
Status: proposal, not implemented yet.

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
| Opt+Shift+h / l | left / right half | `hammerspoon://win?pos=left` |
| Opt+Shift+k / j | top / bottom half | Hammerspoon |
| Opt+Shift+m | cycle: maximized > centered 2/3 > centered 1/2 > maximized | Hammerspoon |

## Focus toggle (Opt+m)

Opt+m always means: focus this one thing, press again to put it back where it was.

| Where | Tap Opt+m | Backend |
|---|---|---|
| Ghostty | tmux: zoom the current pane / unzoom | Karabiner sends `Ctrl+Space`, `m` (existing `bind m resize-pane -Z`) |
| Everywhere else | maximize the window / restore its previous frame | `hammerspoon://win?pos=focus` |

Hold Opt+m (about 250 ms) still types `µ`, in every app. Karabiner: `to_if_alone` = focus toggle,
`to_if_held_down` = `µ`, both thresholds set to the same value. The toggle fires on key release.

## OS layer (Hyper)

| Key | Action | Backend |
|---|---|---|
| Cmd+Space | launcher | `hammerspoon://launcher` |
| Hyper+1..6 | go to desktop N | see `desktops.md` |
| Hyper+Shift+1..6 | move window to desktop N | see `desktops.md` |
| Hyper+v | clipboard history | `hammerspoon://clipboard` |
| Hyper+r | reload Hammerspoon | `hammerspoon://reload` |

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

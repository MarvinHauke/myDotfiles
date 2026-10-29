# Hammerspoon

Config: `~/.hammerspoon/`. Hammerspoon only provides actions. The keys that trigger them live in
Karabiner (see `keys.md`), which calls `open -g 'hammerspoon://<action>'`.

## Actions

Bound with `hs.urlevent.bind` in `init.lua`.

| URL | Does | Module |
|---|---|---|
| `launcher` (`?q=/` starts in the file search) | the launcher | `launcher.lua`, `launcher/` (see `launcher.md`) |
| `clipboard` | clipboard history picker | `clipboard.lua` (see `clipboard.md`) |
| `win?pos=<name>` | place the front window: left, right, top, bottom, corners, cycle, focus, screen | `windows.lua` |
| `edit` | open the Finder selection in nvim | `finder.lua` |
| `add` | create a file or folder in Finder | `finder/add.lua` |
| `help` (`?topic=<heading>`) | key help panel. Without a topic it picks one from the front app (`appTopics` in `init.lua`) | `help.lua` |
| `reload` | reload the config | |
| `appname` | show the name of the front app | |

Not triggered by a URL: `capture.lua` watches `/tmp/shots` (see `capture.md`), `finder.lua` tells Karabiner
whether a Finder text field is being edited (variable `finder_editing`).

## Key help panel

`help.lua` shows the first table under `## <topic>` in `~/.config/docs/keys.md`, at the bottom of the screen.
Any key or click closes it. Changing a key means changing that table; nothing in the Lua.

## Adding an action

1. A module with the code, `require` it in `init.lua`.
2. `hs.urlevent.bind("<name>", ...)` in `init.lua`.
3. A Karabiner rule that runs `open -g 'hammerspoon://<name>'`.
4. A row in `keys.md` and in the table above.

## Working with it

- Reload: Hyper+r, or `open -g hammerspoon://reload`. "Config loaded" confirms it.
- Errors: Hammerspoon console (menu bar icon).
- The `hs` command line tool (enabled by `hs.ipc`) can hang, so prefer the URLs.
- Check Lua syntax: `luac -p <file>`.

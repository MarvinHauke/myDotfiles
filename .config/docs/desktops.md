# Desktops

Status: proposal, not implemented yet.

Idea: every topic has a fixed desktop, so "where is it" is always a number.
Desktops choose the topic, tmux organises work inside the terminal. Both stay.

| # | Topic | Apps |
|---|---|---|
| 1 | Terminal | Ghostty (one window, tmux inside) |
| 2 | Browser | Brave, Chrome |
| 3 | Comms | Signal, Telegram, WhatsApp, Teams, Outlook |
| 4 | Music | Ableton Live, Max |
| 5 | Reading | zathura, Xournal++ |
| 6 | Hardware | KiCad, STM32CubeIDE, Arduino IDE |

## Step 1: native Spaces (no new tool)

- [ ] Create 6 desktops in Mission Control.
- [ ] System Settings > Keyboard > Shortcuts > Mission Control: enable "Switch to Desktop 1..6". Karabiner maps Hyper+N to them.
- [ ] Pin apps: Dock icon > Options > Assign To > This Desktop.
- [ ] System Settings > Desktop & Dock: turn off "Automatically rearrange Spaces based on most recent use".
- [ ] Accessibility > Display > Reduce motion (replaces the slide animation with a fast fade).

Limits: no native "move window to desktop N" shortcut, switching is animated, each display has its own set.

## Step 2, only if step 1 annoys: AeroSpace

Open source tiling window manager with its own workspaces. Instant switching, text config
(`~/.config/aerospace/aerospace.toml`), app-to-workspace rules, and a CLI (`aerospace workspace 2`)
that Karabiner can call. It would replace the Hammerspoon window keys (Opt+Shift layer) and AltTab.

## tmux

- One Ghostty window on desktop 1. Projects are tmux sessions (`prefix s` to switch), not extra terminal windows.
- `.zshrc` attaches every new terminal to the session `default`, so a second window mirrors the first one.
- Focus one pane: tap Opt+m (see `keys.md`), the same focus toggle that maximizes a window elsewhere.

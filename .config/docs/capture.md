# Screenshots and screen recording

Status: implemented with the built-in macOS keys. No Karabiner rule, no extra tool.

| Key | What | Result |
|---|---|---|
| Cmd+Shift+3 | full screen | file in `/tmp/shots`, path on the clipboard |
| Cmd+Shift+4 | selection (Space switches to window mode) | file in `/tmp/shots`, path on the clipboard |
| Cmd+Shift+5 | toolbar, also records the screen | file in `/tmp/shots`, path on the clipboard |

How it works:
- The keys are macOS system hotkeys (System Settings > Keyboard > Shortcuts > Screenshots). They run
  `screencaptureui`, the same engine as the CLI `/usr/sbin/screencapture`.
- macOS saves to `/tmp/shots`: `defaults write com.apple.screencapture location /tmp/shots`.
- The floating thumbnail is off, so the file appears at once: `defaults write com.apple.screencapture show-thumbnail -bool false`
  (then `killall SystemUIServer`).
- `~/.hammerspoon/capture.lua` watches the folder. Each new file is renamed to `YYYY-MM-DD_HHMMSS.png`
  (no spaces), its path is copied to the clipboard as text and shown briefly.
- `/tmp` is cleaned by macOS (`com.apple.tmp_cleaner`, daily) and emptied on reboot. Hammerspoon recreates
  `/tmp/shots` at start and every hour; if the folder is missing, macOS saves to the Desktop.
- Keepers are moved out of `/tmp/shots` by hand.

Notes:
- The path is text, so every capture also shows up in the clipboard history (`clipboard.md`).
- For the image itself on the clipboard, add Ctrl to the key (Ctrl+Cmd+Shift+4). That is the macOS default; it
  saves no file.
- With two screens, Cmd+Shift+3 writes two files; the clipboard holds the path of the one processed last.

Later, if needed:
- `mov2gif` / `mov2mp4` shell functions (ffmpeg).
- OCR: `tesseract <file> - | pbcopy`.
- Flameshot (annotation), OBS (multi-source recording). Both open source.

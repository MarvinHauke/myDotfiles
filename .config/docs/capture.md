# Screenshots and screen recording

Status: implemented with the built-in macOS keys. No Karabiner rule, no extra tool.

| Key | What | Result |
|---|---|---|
| Cmd+Shift+3 | full screen | file in `/tmp/shots`, image on the clipboard |
| Cmd+Shift+4 | selection (Space switches to window mode) | file in `/tmp/shots`, image on the clipboard |
| Cmd+Shift+5 | toolbar, also records the screen | file in `/tmp/shots`; for a recording the path is on the clipboard |

How it works:
- The keys are macOS system hotkeys (System Settings > Keyboard > Shortcuts > Screenshots). They run
  `screencaptureui`, the same engine as the CLI `/usr/sbin/screencapture`.
- macOS saves to `/tmp/shots`: `defaults write com.apple.screencapture location /tmp/shots`.
- The floating thumbnail is off, so the file appears at once: `defaults write com.apple.screencapture show-thumbnail -bool false`
  (then `killall SystemUIServer`).
- `~/.hammerspoon/capture.lua` watches the folder. Each new file is renamed to `YYYY-MM-DD_HHMMSS.png`
  (no spaces), a screenshot is put on the clipboard as an image, and the path is shown briefly.
- `/tmp` is cleaned by macOS (`com.apple.tmp_cleaner`, daily) and emptied on reboot. Hammerspoon recreates
  `/tmp/shots` at start and every hour; if the folder is missing, macOS saves to the Desktop.
- Keepers are moved out of `/tmp/shots` by hand.

Notes:
- The clipboard history (`clipboard.md`) is text only, so screenshots do not appear in it. Recording paths do.
- To paste the path of the last screenshot in a shell: `ls -t /tmp/shots | head -1`.

Later, if needed:
- `mov2gif` / `mov2mp4` shell functions (ffmpeg).
- OCR: `tesseract <file> - | pbcopy`.
- Flameshot (annotation), OBS (multi-source recording). Both open source.

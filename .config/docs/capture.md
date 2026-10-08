# Screenshots and screen recording

Cmd+Shift+4 is a macOS system hotkey (id 30 in `com.apple.symbolichotkeys`, System Settings >
Keyboard > Shortcuts > Screenshots). It starts `screencaptureui`, the same engine as the CLI
`/usr/sbin/screencapture`. Natively: Cmd+Shift+3 full screen, +4 selection, +5 toolbar, add Ctrl for clipboard.

Tool: built-in `screencapture`, called by Karabiner (keys in `keys.md`), `ffmpeg` for conversion.
Captures sent to the clipboard show up in the clipboard history (`clipboard.md`).
Temp folder: `/tmp/shots`. macOS cleans `/tmp` daily (`com.apple.tmp_cleaner`). Keepers are moved by hand.

| Key | Command |
|---|---|
| Cmd+Shift+3 | `screencapture -c` |
| Cmd+Shift+4 | `screencapture -ic` |
| Cmd+Shift+Opt+3 | `mkdir -p /tmp/shots && screencapture /tmp/shots/$(date +%F_%H%M%S).png` |
| Cmd+Shift+Opt+4 | same with `-i` |
| Cmd+Shift+5 | same with `-iv` and `.mov` |

To check when implementing: Karabiner's shell needs the Screen Recording permission.

Later, if needed:
- `mov2gif` / `mov2mp4` shell functions (ffmpeg).
- OCR: `screencapture -i f.png && tesseract f.png - | pbcopy`.
- Flameshot (annotation), OBS (multi-source recording). Both open source.

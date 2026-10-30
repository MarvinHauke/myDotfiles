# Config docs (macOS)

Every config file is documented here, one file per topic. Open steps and state live in
`~/.config/CONFIGPLAN.md`, install steps in `~/README.md`.

## Files

| Doc | Answers |
|---|---|
| `keys.md` | which key does what, which layer a new key belongs to. Source of the key help panel |
| `shell.md` | zsh: load order, plugins, shell keys and widgets, places, fzf / zoxide |
| `terminal.md` | Ghostty and tmux: what is changed from the defaults, panes, copy mode, plugins |
| `nvim.md` | neovim: layout of `nvim/`, plugins, LSP, filetype settings |
| `hammerspoon.md` | Hammerspoon modules and the `hammerspoon://` actions Karabiner calls |
| `launcher.md` | what the launcher finds, how files and folders are opened in nvim, Finder or Ghostty |
| `clipboard.md` | what feeds the clipboard history, where it is stored, how to pick from it |
| `capture.md` | screenshots and recording: keys, commands, where files go |
| `dotfiles.md` | the bare repo, branches, install, Homebrew, secrets, commit hook, Claude status line and skill |
| `apps.md` | VS Code, zathura, plain vim |

## Structure

Who calls whom, and where it is configured.

    Karabiner: all hotkeys             karabiner/karabiner.json      keys.md
      |- Hammerspoon                   ~/.hammerspoon/*.lua          hammerspoon.md
          |- launcher sources          ~/.hammerspoon/launcher/      launcher.md
          |- edit                      ~/.local/bin/edit             launcher.md
          |- key help panel            help.lua, reads keys.md       keys.md
      |- Finder keys                   finder.lua (state), finder/add.lua  keys.md
      |- tmux pane zoom (Opt+m)        sends the tmux prefix and m   keys.md
      |- Ableton, cmdAbl               karabiner/assets/complex_modifications/

    Ghostty                            ghostty/config                terminal.md
      |- zsh                           ~/.zshenv > ~/.zprofile > ~/.zshrc   shell.md
          |- starship                  starship/starship.toml        shell.md
          |- zap plugins, fzf, zoxide, direnv   (set up in ~/.zshrc)  shell.md
          |- tmux                      tmux/tmux.conf (tpm plugins)  terminal.md
              |- nvim                  nvim/ (lazy.nvim)             nvim.md
                  |- zathura           zathura/zathurarc (PDFs opened from nvim)

    macOS screenshot keys              defaults com.apple.screencapture   capture.md
      |- Hammerspoon capture.lua       watches /tmp/shots, path to clipboard

    Homebrew installs all of it        brew/Brewfile                 dotfiles.md
    dotfiles (~/.cfg, branch macos) tracks all of it                 dotfiles.md

## Rules

- Hotkeys live only in `karabiner.json`. Hammerspoon exposes actions (`hs.urlevent.bind` in `init.lua`);
  Karabiner calls `open -g hammerspoon://<action>`. Keys inside one app may live in that app's config (Ghostty, zsh).
- Every key is listed in `keys.md`, in a `| Key | Action | ... |` table under its `## <topic>` heading.
  The help panel (Cmd+Shift+Space, `?` in Finder, Space in the launcher and in zsh normal mode) shows the
  first table under a heading, so that table holds the keys and the details go below it.
- Other docs link to `keys.md` instead of repeating keys.
- A config change and its doc change go into the same commit.
- New topic: new file here plus one line in the table above.
- Doc files start with a `# Title` and one line saying what the file covers and where the config lives.
- Secrets go in `~/.env` or `~/.zshrc.local` (both ignored by git), never in a tracked file.

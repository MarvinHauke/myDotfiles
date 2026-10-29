# Dotfiles repo, install, packages

All config is tracked in a bare git repo at `~/.cfg` with `$HOME` as the work tree.
Remote: `MarvinHauke/myDotfiles`. This machine uses the branch `macos`.

## Using it

```zsh
dotfiles status            # the shell function in .zshrc: git --git-dir=$HOME/.cfg --work-tree=$HOME
dotfiles add ~/.config/x   # only tracked or explicitly added files count, the rest of $HOME is ignored
dotfiles commit
dotfiles-lg                # lazygit on the repo
```

`dotfiles pull` doesn't overwrite files you changed locally. To take the repo's version, remove the file and
`dotfiles checkout -- <file>`.

## Branches

| Branch | For |
|---|---|
| `macos` | this machine |
| `linux`, `linux-android` | Linux desktops, Termux |
| `raspbian` | Raspberry Pi: stripped-down nvim, apt packages in `.config/apt/packages.txt` |
| `Windows_NT` | Windows |
| `main` | the install script `.config/myDotfiles_install.sh` |

## Install on a new Mac

`~/README.md` has the one-liner. It runs the install script (gist `3cd5967bf33fee9350d1fc552138e08e`; keep it
identical to `.config/myDotfiles_install.sh` on `main`): clone to `~/.cfg`, back up conflicting files to
`~/.dotfiles-backup`, check out `macos`, `brew bundle`.

## Homebrew

`~/.config/brew/Brewfile` (`HOMEBREW_BUNDLE_FILE` in `.zshrc`): taps, CLI tools, apps, global go/cargo/npm tools.

| Command | Does |
|---|---|
| `brew bundle dump --force` | write what is installed into the Brewfile |
| `brew bundle` | install what the Brewfile lists |
| `brew bundle cleanup` | list what is installed but not in the file |

## Secrets and the commit hook

- Secrets go in `~/.env` or `~/.zshrc.local`, both untracked.
- `~/.config/git/hooks/pre-commit` runs gitleaks before each commit (a warning only, if gitleaks is missing).
  It also warns, without blocking, when config files are staged without a change in `.config/docs/`
  (Markdown, `lazy-lock.json` and the Brewfile don't count as config).
  Enable per machine: `dotfiles config core.hooksPath ~/.config/git/hooks`.
- Global git ignores: `~/.config/git/ignore`.

## Claude

The skill `~/.claude/skills/dotfiles-docs` holds the doc rules and which doc belongs to which config.
Other sessions only see its one-line description.

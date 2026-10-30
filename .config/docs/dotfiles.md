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

The install one-liner (`~/README.md`) checks out the branch that fits the system:

| Branch | For | Picked when |
|---|---|---|
| `macos` | this machine | macOS |
| `linux` | Linux desktops | Linux on x86_64 |
| `raspbian` | Raspberry Pi: stripped-down nvim, apt packages in `.config/apt/packages.txt` | Linux on aarch64 |
| `linux-android` | Termux | Android |
| `Windows_NT` | Windows | never: the script is bash, check this branch out by hand |
| `main` | the install script `.config/myDotfiles_install.sh` | any other system |

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

## Docs site

`.config/docs/` is published to https://marvinhauke.github.io/myDotfiles/ with MkDocs Material.

| File | Does |
|---|---|
| `~/.github/mkdocs.yml` | site settings and `nav`, the page order. A new doc needs a line there |
| `~/.github/workflows/docs.yml` | GitHub Action: builds the site and deploys it to Pages |

It rebuilds on every push to `macos` that changes `.config/docs/` or `.github/`, or by hand under Actions.
The build is `--strict`: a link to a missing page fails it. Pages source is "GitHub Actions", and the
`github-pages` environment allows deploys from `macos` (the default branch is `main`).

Preview locally: `uvx --with mkdocs-material mkdocs serve -f ~/.github/mkdocs.yml`, then http://127.0.0.1:8000.
A local build writes `~/site/` (ignored by git).

## Claude

The skill `~/.claude/skills/dotfiles-docs` holds the doc rules and which doc belongs to which config.
Other sessions only see its one-line description.

Status line: `~/.claude/statusline.sh` (model, session and weekly limits, context). Progress bars fill the
spare width; when they don't fit, the reset clock times go first, then the bars. With vim mode on it shows a
yellow NORMAL block or a grey "insert" (the cursor itself stays a thin bar in both modes).
`~/.claude/settings.json` is not tracked; on a new machine add
`"statusLine": {"type": "command", "command": "~/.claude/statusline.sh"}` and `"editorMode": "vim"` there.

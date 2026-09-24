# Public Dotfiles

Managed by `dfm` (Homebrew cask `tammersaleh/tap/dotfiles-manager`; `alias dotfiles=dfm`). Files here get symlinked into `$HOME` by `dfm install`. See the `/dotfiles` skill for usage and the `dotfiles-manager` skill for the full command and JSON contract.

## .stow-local-ignore

Files matching patterns in `.stow-local-ignore` are never linked into `$HOME`. `dfm` reads this file with the same semantics stow did: one Perl regex per line, replacing the default ignore list entirely. Add entries here for repo-only files (like this one).

## settings.local.json

Claude Code auto-generates `.claude/settings.local.json` in whatever directory you're working in. If one appears in this repo, delete it. `dfm install` reports it as a conflict with the real one in `$HOME` and exits 2 without changing anything.

## Pushing

Personal repo - always `git push` after committing. Don't ask.

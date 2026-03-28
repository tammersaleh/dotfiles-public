# Public Dotfiles

Managed via GNU Stow. Files here get symlinked into `$HOME` by `dotfiles install`. See the `/dotfiles` skill for full usage.

## .stow-local-ignore

Files matching patterns in `.stow-local-ignore` are excluded from stowing. Add entries there for repo-only files (like this one) that shouldn't appear in `$HOME`.

## settings.local.json

Claude Code auto-generates `.claude/settings.local.json` in whatever directory you're working in. If one appears in this repo, delete it - it'll conflict with the real one in `$HOME` during `dotfiles install`.

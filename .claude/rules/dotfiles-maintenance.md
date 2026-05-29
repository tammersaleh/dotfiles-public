# Dotfiles Maintenance

`~/dotfiles/public` is a git repo; `~/.claude`, `~/packages`, and friends
symlink into it.

## Commit and push after package or skill changes

Updating a package or an agent skill writes into this repo - a package edit
touches `packages/Brewfile`; `skills update` (and `~/packages/go`, which runs
it) rewrites `.agents/skills/<name>/` and `.agents/.skill-lock.json`. Whenever
you make such a change, commit and push it.

Stage only the files your change touched. The working tree usually holds
Tammer's unrelated in-progress edits - never sweep those in. Use a scoped
conventional commit (e.g. `chore(skills): update slack-cli skill`).

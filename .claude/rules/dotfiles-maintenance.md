# Dotfiles Maintenance

`~/dotfiles/public` is a git repo. `~/.claude`, `~/packages`, and friends symlink into it.

## Commit and push after package changes

A package edit touches `packages/Brewfile`, and adding an agent skill touches `packages/skills.txt`. Whenever you make such a change, commit and push it.

`skills update` writes only under `~/.agents`, which dotfiles does not track. It leaves nothing to commit.

Stage only the files your change touched. The working tree usually holds Tammer's unrelated in-progress edits - never sweep those in. Use a scoped conventional commit (e.g. `chore(packages): add ripgrep`).

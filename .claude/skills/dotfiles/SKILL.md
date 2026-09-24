---
name: dotfiles
description: Context for managing dotfiles. Use when editing config files in $HOME that may be symlinks managed by dfm (the dotfiles manager), or when deciding whether a file belongs in the public or private dotfiles repo.
---

# Dotfiles Management

This user's home directory dotfiles are managed by `dfm` from `~/dotfiles/`. Many files in `$HOME` are symlinks pointing into that directory.

## Structure

- `~/dotfiles/public/` - Public git repo (github: dotfiles-public). Non-sensitive configs.
- `~/dotfiles/private/` - Private git repo. Encrypted via git-crypt (key in 1Password).

Both repos are packages that `dfm` links into `$HOME` with stow's folding semantics. For example, `~/.gitconfig` is a symlink to `~/dotfiles/public/.gitconfig`, and `~/.config/gh/hosts.yml` is a symlink to `~/dotfiles/private/.config/gh/hosts.yml`. A directory only one repo populates is one folded symlink; a directory both populate is a real directory with each child linked.

## The `dfm` CLI

Homebrew cask `tammersaleh/tap/dotfiles-manager`. `alias dotfiles=dfm`, so `dotfiles install` and `dfm install` are the same. Load the `dotfiles-manager` skill before running it; it has the full grammar, JSON rows, and error codes.

### Commands

- `dfm status` - Read-only. Per repo: dirty or clean, ahead or behind. Then every conflict and broken link the next `install` would hit. Never fetches or writes. Run this first.
- `dfm install` - Reconciles all symlinks for both repos. Idempotent. Run after any changes to files inside the repos. Exit 2 on a conflict (a path in `$HOME` exists and is not a dfm symlink); nothing changed.
- `dfm public PATH` - Moves a path from `$HOME` into the public repo and re-installs.
- `dfm private PATH` - Same, into the private repo. Use for anything containing secrets or credentials.
- `dfm ignore PATH` - Adds the path to the `.gitignore` of the repo that owns it. Ownership is autodetected from the symlink chain.
- `dfm pull` - Fetches and rebases both repos, re-installs, runs each repo's `post-pull.sh`. Refuses with `dirty_tree` if either repo has uncommitted changes; nothing is stashed. `--no-hooks` skips the hooks.

Paths are relative to `$HOME` or absolute; no need to run from `$HOME`. Every mutating command takes `--dry-run` (print the plan, change nothing). `--json` gives JSONL on stdout.

## Rules

- Before editing any dotfile in `$HOME`, check if it's a symlink (`ls -la`). If it is, it's managed by this system.
- NEVER overwrite a dfm-managed symlink with a regular file. Edit the symlink target (or edit in place, which follows the symlink).
- NEVER manually move or copy files into the repos, or use `mkdir` to create directories there. Always use `dfm public` or `dfm private` to track new files.
- When tracking a directory, pass the directory itself (e.g. `dfm public .claude/skills/dotfiles`), not individual files within it.
- After adding, removing, or renaming files inside `~/dotfiles/public/` or `~/dotfiles/private/`, run `dfm install`.
- A conflict (exit 2) means stop and report. Don't delete or move the conflicting path; the human decides between `dfm public PATH` and removing it.
- Use the private repo for anything sensitive: tokens, keys, credentials, machine-specific config, or anything referencing the user's employer or workplace. The public repo is on GitHub - treat it accordingly.
- Each repo has its own git history. Commit changes in the appropriate repo after modifications.

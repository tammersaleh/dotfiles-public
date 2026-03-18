---
name: dotfiles
description: Context for managing dotfiles. Use when editing config files in $HOME that may be symlinks managed by stow.
---

# Dotfiles Management

This user's home directory dotfiles are managed via GNU Stow from `~/dotfiles/`. Many files in `$HOME` are symlinks pointing into that directory.

## Structure

- `~/dotfiles/public/` - Public git repo (github: dotfiles-public). Non-sensitive configs.
- `~/dotfiles/private/` - Private git repo. Encrypted via git-crypt (key in 1Password).

Both repos are "stowed" into `$HOME`, meaning stow creates symlinks in `$HOME` pointing to the corresponding files in each repo. For example, `~/.gitconfig` is a symlink to `~/dotfiles/public/.gitconfig`, and `~/.config/gh/hosts.yml` is a symlink to `~/dotfiles/private/.config/gh/hosts.yml`.

## The `dotfiles` CLI

Located at `~/dotfiles/public/bin/dotfiles`.

### Commands

- `dotfiles install` - Runs `stow --restow public private` to reconcile all symlinks. Idempotent. Run this after any changes to files inside the repos.
- `dotfiles public FILE` - Moves a file from `$HOME` into the public repo and re-installs. Must be run from `$HOME`.
- `dotfiles private FILE` - Same as above but into the private repo. Use for anything containing secrets or credentials.
- `dotfiles ignore FILE` - Adds a path to the public `.gitignore`.
- `dotfiles pull` - Fetches and rebases both repos, re-installs, and runs any `post-pull.sh` hooks.

## Rules

- Before editing any dotfile in `$HOME`, check if it's a symlink (`ls -la`). If it is, it's managed by this system.
- NEVER overwrite a stow-managed symlink with a regular file. Edit the symlink target (or edit in place, which follows the symlink).
- NEVER manually move or copy files into the repos, or use `mkdir` to create directories there. Always use the `dotfiles` CLI to track new files.
- When tracking a new file, use `dotfiles public FILE` or `dotfiles private FILE` from `$HOME`.
- When tracking a directory, pass the directory itself (e.g. `dotfiles public .claude/skills/dotfiles`), not individual files within it.
- After adding, removing, or renaming files inside `~/dotfiles/public/` or `~/dotfiles/private/`, run `dotfiles install`.
- Use the private repo for anything sensitive: tokens, keys, credentials, machine-specific config, or anything referencing the user's employer or workplace. The public repo is on GitHub - treat it accordingly.
- Each repo has its own git history. Commit changes in the appropriate repo after modifications.

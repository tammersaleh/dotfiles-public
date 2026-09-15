# Git Hygiene

## Never stash or rebase over the user's uncommitted work

The working tree usually holds Tammer's in-progress edits. Anything that
shelves or replays them - `git stash`, `git pull --rebase`, `git rebase`, and
especially `git pull --rebase --autostash` - can leave his files conflicted or
reordered behind his back.

Before running any such command, check `git status`. If the tree is dirty with
changes you didn't make:

- Commit your own work first with explicit pathspecs (`git commit -- path ...`),
  then operate only on your commits.
- If a `git pull` is rejected as non-fast-forward, rebase or merge *your
  commits* on top - never autostash his.
- If you genuinely need his tree clean and can't avoid it, stop and ask. Don't
  stash on his behalf.

The goal: your changes never disturb his uncommitted edits.

## In dotfiles, commit and push your own files even when the tree is dirty

When working in `~/dotfiles/public`, an unrelated modified file in the tree is
never a reason to skip committing. Stage only the files your change touched
(explicit pathspecs), commit, and push. Leave everything else unstaged. Don't
ask - do it.

## Scrub sensitive information before pushing to public repos

Before pushing to a public repo, or creating a new public repo, check every
commit being pushed for sensitive information. Anything about CoreWeave counts,
including the name "CoreWeave" itself. Also look for credentials, internal
hostnames, customer names, and internal URLs (Slack, Confluence, Jira).

Check the repo's visibility with `gh repo view --json isPrivate` when unsure. If
anything sensitive turns up, stop and ask before pushing.

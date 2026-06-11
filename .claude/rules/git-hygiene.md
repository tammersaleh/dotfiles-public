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

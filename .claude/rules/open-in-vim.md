# Open files in the wrapping nvim

When Tammer says "let me edit that", "v that for me", "open that in vim",
"open in nvim", or otherwise wants to edit a file by hand, open it as a split
in his wrapping nvim instead of editing it yourself. Use the `open-in-vim`
skill.

Only works inside an nvim `:terminal` (the `$NVIM` env var is set). Always go
through the guarded wrapper `~/.claude/skills/open-in-vim/v-open` - never call
plain `v`, which launches a blocking editor when `$NVIM` is unset. If the
wrapper refuses (`$NVIM` unset), say so and edit with the normal tools.

## Proactively offer to open new drafts

Whenever you create a markdown file or any text file for Tammer to
review or edit, offer to `v` it for him in the same turn. Don't wait to
be asked.

## Check for NB notes after review

When Tammer finishes with a file you opened for feedback, re-read the whole
file and search it for `NB` notes (`rg -n '\bNB\b' <path>`). Each NB note is a
question or instruction from Tammer. Answer or act on every one, then remove
the note. Never treat the file as approved without this check.

## Re-read before every write

Once a file has been opened for Tammer, he may be editing it. Before any write
to it (Edit, Write, sed, a script), re-read the file from disk and diff it
against what you last wrote. Build on his version; never overwrite his
changes. If his edits conflict with yours, show the conflict and ask.
(Tammer, 2026-10-06)

# Open files in the wrapping nvim

When Tammer says "let me edit that", "v that for me", "open that in vim",
"open in nvim", or otherwise wants to edit a file by hand, open it as a split
in his wrapping nvim instead of editing it yourself. Use the `open-in-vim`
skill.

Only works inside an nvim `:terminal` (the `$NVIM` env var is set). Always go
through the guarded wrapper `~/.claude/skills/open-in-vim/v-open` - never call
plain `v`, which launches a blocking editor when `$NVIM` is unset. If the
wrapper refuses (`$NVIM` unset), say so and edit with the normal tools.

---
name: slack-table
description: >-
  Hand Tammer a table he can paste into Slack. Triggers on "table I can paste
  into slack", "slack format", "format this for slack", "give me that table for
  slack", or any request to put tabular data into a Slack message. Markdown pipe
  tables and aligned code blocks do not render as tables in Slack; this skill
  covers the one path that does.
---

# Tables for Slack

Slack renders a native table only from tab-separated text pasted into the message box. Markdown pipe tables paste as literal garbage. Monospace code blocks are a fallback, not a table.

## Steps

1. Build the table as TSV: one header row, one row per record, tab between cells, newline between rows. No leading or trailing whitespace in cells.
2. Pipe it to the clipboard and verify the tabs survived:

```bash
printf 'Person\tCount\nWilly\t3\n' | pbcopy && pbpaste | cat -A
```

3. Tell Tammer the table is on his clipboard and to Cmd-V into the Slack message box.
4. Show the same table as markdown in chat so he can read it without pasting.

## Rules

- One TSV block is one table. Several tables need several pastes.
- Keep emoji and wide glyphs out of aligned columns, or in the last column.
- Never post or stage the table in Slack yourself. Clipboard only.
- Any other form, such as `column -t`, box drawing, or a pipe table, is wrong for Slack.

Source: Josh Frantz's rule, https://github.com/coreweave/jfrantz-dotfiles/blob/main/claude/rules/slack-tables.md.

---
name: slack-saved-items
description: "List Slack messages saved for later"
argument-hint: ""
allowed-tools:
  - Bash(uv run --project /Users/tammersaleh/.claude/skills/slack-saved-items *)
---

# Saved Items Skill

Lists messages from Slack's "Save for Later" feature using the internal
`saved.list` API.

## Prerequisites

Same env vars as `organize-channels`:

| Variable | Purpose |
|----------|---------|
| `SLACK_MCP_XOXC_TOKEN` | Slack session token (xoxc-) |
| `SLACK_MCP_XOXD_TOKEN` | Slack cookie token (xoxd-) |
| `SLACK_MCP_USER_AGENT` | Slack client User-Agent string |

## Usage

All commands via:

```bash
uv run --project /Users/tammersaleh/.claude/skills/slack-saved-items python /Users/tammersaleh/.claude/skills/slack-saved-items/scripts/saved_items.py <command> [options]
```

All commands accept `--pretty`.

### `counts`

Show summary counts (uncompleted, overdue, completed, total).

### `list [--limit N] [--enrich] [--include-completed]`

List saved items. Default limit is 20.

- `--enrich` fetches actual message text and channel names (slower, makes
  extra API calls per item).
- `--include-completed` includes items already marked done.

### `auth-test`

Verify tokens are valid.

---
name: gdocs
description: "Use for any Google Docs, Sheets, or Drive URL (docs.google.com/document/*, docs.google.com/spreadsheets/*, drive.google.com/drive/folders/*). Reads/writes documents and spreadsheets, lists Drive folders, manages comments. Activate on any docs.google.com or drive.google.com link."
allowed-tools: Bash(uv run --project ~/.claude/skills/gdocs python ~/.claude/skills/gdocs/scripts/*.py *), Bash(~/.claude/scripts/cdp-fetch.sh *)
requires-credentials:
  - GDOCS_APPSCRIPT_URL
  - GDOCS_APPSCRIPT_KEY
setup-skill: gdocs-setup
auto-refresh: false
---

# Google Docs Operations

Read and write access to Google Docs and Google Drive folders. Uses a Google Apps Script web app as the backend, with requests routed through the Chrome debug instance (CDP) for Okta SSO authentication.

Apps Script editor: https://script.google.com/home/projects/1A_NY5VTc8G2W1py2wONJ98ILmdMpOJceJLY1KxNbdnlUwcmDo3V5aHUg/edit

## Prerequisites

- `GDOCS_APPSCRIPT_URL` and `GDOCS_APPSCRIPT_KEY` environment variables set (run `/gdocs-setup` if not done)
- Chrome debug instance running: `~/.claude/scripts/chrome-debug.sh start`
- Signed into Okta in the Chrome debug instance
- Python dependencies installed: `cd ~/.claude/skills/gdocs && uv sync`
- **For write operations**: Apps Script must be redeployed with the updated `Code.gs` that includes write handlers. Google may prompt for additional permissions on first write.
- **Google Docs API** Advanced Service enabled in the Apps Script editor (Services > + > Google Docs API > Add). Required for smart chip support (person mentions, dates, rich links).

## Deploying Code.gs Changes

The on-disk `Code.gs` contains the real API key from `$GDOCS_APPSCRIPT_KEY`. When copying to clipboard for deployment, **do not** replace the key with a placeholder. The file should always have the real key so it's ready to paste directly into the script editor.

After pasting into the Apps Script editor: Save, then Deploy > Manage deployments > edit the active deployment > Deploy.

## Python Tools

All Python tools output JSON to stdout and errors to stderr. Use `--pretty` for human-readable output.

**Invocation pattern:**
```bash
uv run --project ~/.claude/skills/gdocs python ~/.claude/skills/gdocs/scripts/<tool>.py <command> [options]
```

### drive.py

List files and subfolders in Google Drive folders.

**Subcommands:**
- `ls` - List files and subfolders in a folder by ID or URL

```bash
# List by folder ID
uv run --project ~/.claude/skills/gdocs python ~/.claude/skills/gdocs/scripts/drive.py ls --id 1qxNCV1dWSE80KeUaZKwxv7WIE8RjcCSL --pretty

# List by folder URL
uv run --project ~/.claude/skills/gdocs python ~/.claude/skills/gdocs/scripts/drive.py ls --url "https://drive.google.com/drive/folders/1qxNCV1dWSE80KeUaZKwxv7WIE8RjcCSL" --pretty
```

### sheets.py

Read and write Google Sheets spreadsheets.

**Subcommands:**

- `info` - Get spreadsheet metadata (sheet names, row/column counts)
- `read` - Read cells from a sheet (defaults to all data in first sheet)
- `write` - Write a 2D array of values to a range

```bash
# Get spreadsheet info
uv run --project ~/.claude/skills/gdocs python ~/.claude/skills/gdocs/scripts/sheets.py info --id SPREADSHEET_ID --pretty

# Read all data from first sheet
uv run --project ~/.claude/skills/gdocs python ~/.claude/skills/gdocs/scripts/sheets.py read --id ID --pretty

# Read a specific range from a named sheet
uv run --project ~/.claude/skills/gdocs python ~/.claude/skills/gdocs/scripts/sheets.py read --id ID --sheet "Sheet1" --range "A1:D10" --pretty

# Read as CSV
uv run --project ~/.claude/skills/gdocs python ~/.claude/skills/gdocs/scripts/sheets.py read --id ID --csv

# Write values (JSON 2D array)
uv run --project ~/.claude/skills/gdocs python ~/.claude/skills/gdocs/scripts/sheets.py write --id ID --range "A1" --values '[["Name","Score"],["Alice",95]]' --pretty
```

### documents.py

Read, create, update, and append to Google Docs documents.

**Read subcommands:**
- `get` - Get a document's content by ID or URL
- `comments` - List comments on a document

**Write subcommands:**
- `create` - Create a new document
- `update` - Replace a document's entire content
- `append` - Append content to an existing document
- `comment` - Add a comment to a document
- `resolve-comment` - Resolve a comment

### Read Operations

```bash
# Get a document by ID
uv run --project ~/.claude/skills/gdocs python ~/.claude/skills/gdocs/scripts/documents.py get --id 1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgVE2upms --pretty

# Get a document by URL
uv run --project ~/.claude/skills/gdocs python ~/.claude/skills/gdocs/scripts/documents.py get --url "https://docs.google.com/document/d/1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgVE2upms/edit" --pretty
```

### Write Operations (Require Explicit User Confirmation)

**IMPORTANT: Never execute write operations without explicit user confirmation.** Before running any create, update, or append command, show the user what will be written and get their approval.

#### Create a document

Ask the user to confirm: document title, content summary, and format.

```bash
# Create with plain text
uv run --project ~/.claude/skills/gdocs python ~/.claude/skills/gdocs/scripts/documents.py create \
  --title "Meeting Notes — Jane Street 2026-02-21" \
  --content "Attendees: Fabian, John\n\nAgenda:\n- Delivery status\n- IB fabric update" \
  --pretty

# Create with Markdown formatting
uv run --project ~/.claude/skills/gdocs python ~/.claude/skills/gdocs/scripts/documents.py create \
  --title "Delivery Analysis" \
  --content "# DH2 Delivery Status\n\n**Target**: 541 B200 nodes\n\n## Timeline\n\n- Phase 1: 200 nodes\n- Phase 2: 341 nodes\n\n[Jira Epic](https://coreweave.atlassian.net/browse/TSM-105)" \
  --format markdown --pretty

# Create with content from a file
uv run --project ~/.claude/skills/gdocs python ~/.claude/skills/gdocs/scripts/documents.py create \
  --title "Technical Analysis" \
  --file /tmp/analysis.md --format markdown --pretty

# Create title-only (empty document)
uv run --project ~/.claude/skills/gdocs python ~/.claude/skills/gdocs/scripts/documents.py create \
  --title "Scratch Pad" --pretty
```

#### Update a document (replaces all content)

**Warn the user that this REPLACES ALL existing content.** Fetch the document first with `get` to confirm the target.

```bash
uv run --project ~/.claude/skills/gdocs python ~/.claude/skills/gdocs/scripts/documents.py update \
  --id DOC_ID --content "Completely new content." --pretty

# Update with Markdown from a file
uv run --project ~/.claude/skills/gdocs python ~/.claude/skills/gdocs/scripts/documents.py update \
  --id DOC_ID --file updated-notes.md --format markdown --pretty
```

#### Append content to a document

```bash
# Append text
uv run --project ~/.claude/skills/gdocs python ~/.claude/skills/gdocs/scripts/documents.py append \
  --id DOC_ID --content "Additional notes from follow-up call." --pretty

# Append with a horizontal rule separator
uv run --project ~/.claude/skills/gdocs python ~/.claude/skills/gdocs/scripts/documents.py append \
  --id DOC_ID --content "## Action Items\n\n- Follow up on IB flaps\n- Schedule QBR" \
  --format markdown --separator --pretty

# Append from stdin
echo "Appended via pipe" | uv run --project ~/.claude/skills/gdocs python ~/.claude/skills/gdocs/scripts/documents.py append \
  --id DOC_ID --file - --pretty
```

### Comment Operations

```bash
# List unresolved comments on a document
uv run --project ~/.claude/skills/gdocs python ~/.claude/skills/gdocs/scripts/documents.py comments --id DOC_ID --pretty

# List all comments (including resolved)
uv run --project ~/.claude/skills/gdocs python ~/.claude/skills/gdocs/scripts/documents.py comments --id DOC_ID --include-resolved --pretty

# Add a comment to a document
uv run --project ~/.claude/skills/gdocs python ~/.claude/skills/gdocs/scripts/documents.py comment --id DOC_ID --content "This section needs updating" --pretty

# Resolve a comment
uv run --project ~/.claude/skills/gdocs python ~/.claude/skills/gdocs/scripts/documents.py resolve-comment --id DOC_ID --comment-id COMMENT_ID --pretty
```

Comments include the `quotedText` field showing what text the comment is anchored to (if any), the author, and any replies. Use `comments` to read feedback, then `resolve-comment` after addressing each one.

## Google Docs URL Format

Google Docs URLs follow this pattern:
```
https://docs.google.com/document/d/<DOCUMENT_ID>/edit
```

The `--url` flag automatically extracts the document ID from the URL. You can also pass just the `--id` directly.

## Content Sources

Content can be provided via:
- `--content "inline text"` — for short content passed directly
- `--file path/to/file.md` — for longer content read from a file
- `--file -` — read content from stdin (useful for piping)

These are mutually exclusive. For `create`, content is optional (creates an empty document). For `update` and `append`, content is required.

## Markdown Formatting

When using `--format markdown`, the following elements are converted to native Google Docs formatting:

| Markdown | Google Docs Result |
|---|---|
| `# Heading 1` through `###### Heading 6` | Native heading levels |
| `**bold**` | Bold text |
| `*italic*` or `_italic_` | Italic text |
| `***bold italic***` | Bold + italic text |
| `` `code` `` | Courier New font with gray background |
| `- item` or `* item` | Bullet list |
| `1. item` | Numbered list |
| `[text](url)` | Hyperlink |
| `---` or `***` | Horizontal rule |
| `> quote` | Indented italic paragraph |
| ` ``` code ``` ` | Code block (Courier New, gray background) |

**Not supported:** Tables, images, nested lists, footnotes. Use plain text or Confluence for complex formatting.

## Large Content Handling

Content larger than ~5000 characters is automatically chunked into multiple requests. The first chunk uses the specified format; continuation chunks are appended as plain text. This is transparent — no special handling needed. For very large Markdown documents, prefer splitting content at paragraph boundaries (blank lines) for best results.

## Output Format

All commands return JSON:
```json
{
  "ok": true,
  "id": "DOCUMENT_ID",
  "title": "Document Title",
  "body": "Full plain text content...",
  "url": "https://docs.google.com/document/d/<id>/edit",
  "message": "Document created"
}
```

The `message` field is present on write operations (`Document created`, `Document updated`, `Content appended`).

## Error Checking

Common errors:
- **`unauthorized`**: API key mismatch — check `GDOCS_APPSCRIPT_KEY` env var matches the key in your Apps Script
- **`not_found`**: Document not found or no access — verify the document ID and sharing permissions
- **`permission_denied`**: The Apps Script's Google account doesn't have access to the document
- **`missing_param`**: Required parameter not provided (e.g., title for create, content for update)
- **Chrome not running**: Start with `~/.claude/scripts/chrome-debug.sh start`
- **Timeout or Okta auth errors**: The Okta session has likely expired. Offer to re-authenticate by running `~/.claude/scripts/chrome-debug.sh stop` then `~/.claude/scripts/chrome-debug.sh start --visible` to open a visible Chrome window. Ask the user to sign into Okta in that window and tell you when they're done. Then run `~/.claude/scripts/chrome-debug.sh stop` and `~/.claude/scripts/chrome-debug.sh start` to restart headless, and retry the original request.
- **`internal`**: Apps Script execution error — check the Executions log in the Apps Script editor

## Safety Rules

- **Read operations execute without asking.** The `get` command can run freely.
- **Write operations require user confirmation.** Always confirm with the user before creating, updating, or appending. Display the operation details before proceeding.
- **Show what will change before writes.** For `create`: show title and content summary. For `update`: warn that this REPLACES ALL content and show the document title. For `append`: show what will be added.
- **Prefer append over update.** When adding content to an existing document, use `append` instead of `update` unless the user explicitly wants to replace everything.
- **No delete operation.** Documents cannot be deleted through this skill — manage document lifecycle in Google Drive directly.
- **Respect privacy.** Only access documents relevant to the user's request.
- **New documents are private.** Created documents are owned by and visible only to the Apps Script deployer. Share manually in Google Drive if needed.

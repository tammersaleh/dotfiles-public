---
name: slack-cli
description: "Read and manage Slack workspaces: messages, channels, users, files, saved items, sidebar sections"
argument-hint: ""
allowed-tools:
  - Bash(slack *)
---

# Slack CLI

CLI for Slack. JSONL output (one JSON object per line). All commands end with
a `_meta` trailer: `{"_meta":{"has_more":false}}`.

Requires the `slack` binary on PATH. If `command not found`, install it:
`brew install tammersaleh/tap/slack-cli` (macOS) or
`go install github.com/tammersaleh/slack-cli/cmd/slack@latest`.

Auth is pre-configured. If you get `not_authed`, tell the user to run
`slack auth login`.

## Output

Every command writes JSONL to stdout. Filter fields with `--fields id,name`.
Suppress stdout with `--quiet`. Errors go to stderr as JSON.

## Errors

Every fatal error on stderr is one JSON object:

- `error` - stable code (e.g. `channel_not_found`)
- `detail` - human-readable context
- `hint` - runnable recovery command, when available. **Read this and do what it says.**
- `input` - the specific input that failed (channel, user, ts, draft id, ...)
- `endpoint` - Slack API endpoint, only on upstream API failures

Common errors and their recovery:

| `error` | What to run next |
|---|---|
| `not_authed` | `slack auth login --desktop` (or `slack auth login` for OAuth) |
| `channel_not_found` | `slack channel list --query <partial>`; add `--include-non-member` for channels you haven't joined |
| `user_not_found` | `slack user list --query <partial>` or `slack user info <id-or-email>` |
| `draft_not_found` | `slack draft list` (add `--include-sent` / `--include-deleted` for hidden ones) |
| `section_not_found` | `slack section list` |
| `thread_not_found` | `slack message list <channel> --has-replies` to find threads |
| `invalid_timestamp` | RFC 3339, `YYYY-MM-DD`, or raw Slack ts (`1713300000.123456`). Match the `hint`. |
| `invalid_blocks` / `missing_blocks` | Block Kit JSON on stdin; drafts require only `rich_text` top-level blocks. See draft docs below. |
| `rate_limited` | Retry after the delay Slack provided |

Per-item errors in bulk commands (e.g. `slack channel info X Y Z`)
go to stdout inline as `{"input":..., "error":..., "detail":..., "hint":...}`
rows and set `_meta.error_count` in the trailer. Exit code is 1.

### Exit codes

- 0 - success
- 1 - general error (including partial failure in bulk commands)
- 2 - authentication required / not authed
- 3 - rate limited
- 4 - network error

## Commands

**Prefer URLs.** Default to passing a Slack URL whenever you have one - a
message permalink, channel link, user profile link, or file link. It's the most
reliable input and it's what the examples below use. `search` and `saved list`
rows carry a `permalink`, the human often pastes a link, and `slack message
permalink` mints one on demand, so the usual loop is *discover → take the
`permalink` → act on it*.

A message permalink fills both the channel and the timestamp at once for
`message get`, `reaction list`, and `thread list`, and several may target
different channels in a single call; a link to any reply resolves to its parent
thread. `file info`/`download` take file links.

IDs (`C…`/`U…`/`F…`), `#channel`/`@user` names, and emails work anywhere a URL
does - reach for them when you don't have a link (see Channel and User
Resolution). A URL of the wrong kind (a user link where a channel is expected)
is rejected as `invalid_input`.

### Messages

```
slack message list <channel> [--limit N] [--after TS] [--before TS] [--has-replies] [--has-reactions]
slack message get <channel> <ts>...
slack message get <message-url>...
slack message permalink <channel> <ts>...
```

Time bounds accept RFC 3339, `YYYY-MM-DD`, or raw Slack ts.
`--unread` uses the channel's last_read marker (mutually exclusive
with `--after`). `--has-replies` is a client-side filter - use it
to find threads worth exploring with `slack thread list`.

Examples:

```
slack message get https://acme.slack.com/archives/C01ABC/p1709251200000100
slack message get <perma-a> <perma-b>                      # several at once, may span channels
slack message list https://acme.slack.com/archives/C01ABC --limit 50
slack message list https://acme.slack.com/archives/C01ABC --after 2026-04-01 --has-replies
```

### Threads

```
slack thread list <channel> <ts> [--limit N]
slack thread list <message-url> [--limit N]
```

Pair with `slack message list --has-replies` to locate a thread root
first. `ts` is the parent message's timestamp; a permalink to any reply
also works - it resolves to the parent thread.

```
slack thread list https://acme.slack.com/archives/C01ABC/p1709251200000100
```

### Search (requires user token)

```
slack search messages <query> [--limit N] [--sort timestamp|score] [--sort-dir asc|desc]
slack search files <query> [--limit N]
```

Query supports Slack's search modifiers. Combine freely:

- `in:#channel` - only this channel (also works with names, `in:@user` for DMs)
- `from:@user` - messages posted by this user
- `to:@user` - DMs to this user
- `after:YYYY-MM-DD` / `before:YYYY-MM-DD` / `on:YYYY-MM-DD` / `during:month`
- `has:link` / `has:pin` / `has:reaction` / `has:file` / `has:image`
- `is:thread` - messages in threads; `is:saved` / `is:dm` / `is:mpdm`

Example: `"deploy blocker in:#general from:@alice after:2026-01-01"`

Results are ranked by score unless `--sort timestamp`. Each hit
includes `channel` (object with `id`/`name`), `user`, `ts`,
`text`, and `permalink`.

### Channels

```
slack channel list [--limit N] [--type all|public|private|mpim|im] [--query STR] [--include-non-member]
slack channel info <channel>...
slack channel members <channel> [--limit N]
slack channel managers <channel>                       # "Managed by" users (session token)
```

Defaults to channels you're a member of, all types. Add `--include-non-member`
to expand to channels you haven't joined; narrow with `--type`.

Examples:

```
slack channel list --query ext-                        # find customer channels
slack channel list --type private --has-unread         # private + unread
slack channel list --include-non-member --all          # workspace-wide
slack channel info https://acme.slack.com/archives/C01ABC --fields id,name,topic
```

### Users

```
slack user list [--limit N] [--query STR] [--presence]
slack user info [--full] <user>...
slack user manager-chain [--manager-field LABEL] <user>...
```

User arguments accept IDs (`U...`), emails, or `@name` (display
name, username, or real name). On Enterprise Grid with a session
token, email lookup may fail - prefer `@name` there.

Use `--full` whenever you need to know anything about a person beyond
their name. Plain `slack user info` returns `profile.fields: []` - it does
NOT include title, manager, department, or any org data. `--full` fetches
the custom profile fields and adds a top-level `custom_fields` object
(keyed by snake_case label: `manager`, `title`, `division`, `department`,
`employee_id`, etc.). The Manager field is a user ID, resolved to a name in
`value_name`. For "who is X / what's their role / who do they report to",
reach for `--full` first.

`manager-chain` walks the reporting line upward (one row per level, to the
top). Traversal is upward-only - Slack exposes no reliable direct-reports
data. `--full` and `manager-chain` need the `users.profile:read` scope;
desktop auth has it, older OAuth tokens must re-auth.

Examples:

```
slack user info --full @jmancuso                      # title, manager, dept, etc.
slack user info --full @jmancuso | jq '.custom_fields.manager.value_name'
slack user manager-chain @jmancuso                    # full reporting line up
slack user info https://acme.slack.com/team/U01ABC    # by profile link
slack user list --query tamm                          # find by partial name
slack user info @alice U09T3DUS6P9 alice@example.com   # or name / ID / email (incl. bulk)
```

### Files

```
slack file list [--limit N] [--channel CH] [--user UID] [--types images,pdfs]
slack file info <file-id-or-url>...
slack file download <file-id-or-url> [-o path]
```

### Reactions

```
slack reaction list <channel> <ts>...
slack reaction list <message-url>...
```

### Pins and Bookmarks

```
slack pin list <channel>
slack bookmark list <channel>
```

### Saved Items (requires session token)

```
slack saved list [--limit N] [--enrich] [--include-completed]
slack saved counts
```

### Sidebar Sections (requires session token)

```
slack section list
slack section channels <section-id>
slack section find <pattern>
slack section move --channels ID,ID --section ID
slack section move --channels ID,ID --new-section "Name"
slack section create <name>
```

### Drafts (requires session token)

Stage unsent messages. The CLI never sends - the human sends from the
Slack app. Block Kit JSON is piped on stdin; there is no plain-text
shortcut.

```
slack draft list [--active] [--include-sent] [--include-deleted] [--limit N]
slack draft create <channel> [--thread TS [--broadcast]] [--at RFC3339] [--table FILE] < payload.json
slack draft update <draft-id> [--at RFC3339] [--clear-schedule] [--table FILE] [< payload.json]
slack draft delete <draft-id>...
```

#### Block Kit for drafts

stdin is either a bare array of top-level blocks (prose), or an object
`{"blocks":[...],"attachments":[...]}`. Top-level blocks must be
`rich_text` - Slack's draft compose editor strips every other top-level
block type when the user opens the draft, so express `section`/`header`
headings as bold `rich_text` instead. A draft needs renderable content:
at least one `rich_text` block with non-empty `elements`, **or** a table
attachment - one with neither is tombstoned. **Tables go in attachments,
not top-level blocks** (see Tabular data). The CLI rejects bad shapes up
front with `invalid_blocks`.

##### Block types that look right but break

Slack's public docs describe several block types you might reach for.
For drafts specifically, only `rich_text` works. The CLI catches
the cases below at validation - you'll see `invalid_blocks` locally,
not the Slack-side failure - but knowing the underlying reason makes
the rejection less surprising and discourages bypassing the CLI:

- **`markdown` block** (the new CommonMark block Slack
  recommends for LLM output): `drafts.create` returns
  `internal_error` - the drafts API doesn't support it,
  regardless of content.
- **`table` as a *top-level* block**: `drafts.create` returns ok and
  stores it, so it looks supported - but Slack's compose editor strips
  the table when the user opens the draft (and a table-only top-level
  draft, having no `rich_text` body, is tombstoned within seconds).
  Tables are not broken in drafts - they just belong in an
  **attachment**: put the `table` block in `attachments[].blocks[]`,
  where it survives and renders as a Table card. See Tabular data below.
- **`data_table` block** (the interactive variant - pagination,
  sorting, Work Object flexpanes): not draftable anywhere. It is
  stripped from the compose editor and a data_table-only draft is
  tombstoned, even inside an attachment (verified). It is an app-only
  block for posted messages; use a plain `table` for drafts.
- **`section` + `mrkdwn`**: `drafts.create` returns ok,
  but Slack Desktop's Drafts-panel reconciliation tombstones the
  draft (sets `is_deleted=true` on the server) within seconds.
  `drafts.delete` then fails with `draft_delete_invalid`
  because the record is already marked deleted - a leaked draft
  that the user can't see and you can't clean up.
- **Mixed top-level blocks** (`[rich_text, section, divider]`):
  the Drafts compose editor silently strips every non-rich_text
  block when the user opens the draft, so the user sees only the
  rich_text content. Section-only or divider-only arrays - i.e.
  no rich_text body at all - get tombstoned by the reconciliation
  pass within seconds, same mechanism as the previous bullet.
- **Multiple top-level `rich_text` blocks expecting paragraph
  breaks between them**: Desktop flattens adjacent rich_text blocks
  into one before rendering. Always emit a single top-level
  `rich_text` block; use multiple inner containers
  (`rich_text_section`, `rich_text_list`,
  `rich_text_preformatted`, `rich_text_quote`) for
  structure.
- **`rich_text_section` whose text doesn't end with `\n`
  directly followed by `rich_text_list`,
  `rich_text_preformatted`, or `rich_text_quote`**:
  the following container absorbs the section's content. Heading text
  glues onto the first bullet, merges into the code block, or glues
  into the quote. The CLI rejects this locally with
  `invalid_blocks`. Fix: terminate the section with a text
  inline whose `text` ends with `\n` (e.g. append
  `{"type":"text","text":"\n"}`, or grow the last
  text element). The check spans top-level rich_text boundaries because
  Desktop flattens them first.

##### rich_text (structured)

Shape:

```
{type:"rich_text", elements:[ <container>, ... ] }

<container> ∈ rich_text_section | rich_text_list | rich_text_quote | rich_text_preformatted
<inline>    ∈ text | link | user | usergroup | channel | emoji | date | broadcast
```

Minimal rich_text (plain text):

```json
[{"type":"rich_text","elements":[{"type":"rich_text_section","elements":[{"type":"text","text":"hello"}]}]}]
```

##### Container elements

**rich_text_section** - one paragraph. `elements` = array of inline.

```json
{"type":"rich_text_section","elements":[{"type":"text","text":"a sentence"}]}
```

**rich_text_list** - bullet or ordered list. `elements` = array of
rich_text_section (each one is a list item).

```json
{"type":"rich_text_list","style":"bullet","indent":0,"elements":[
  {"type":"rich_text_section","elements":[{"type":"text","text":"item one"}]},
  {"type":"rich_text_section","elements":[{"type":"text","text":"item two"}]}
]}
```

- `style` is `bullet` or `ordered`.
- `indent` is 0, 1, 2 for nesting depth.
- `border` is 0 (none) or 1 (thin left border).

Nesting: a rich_text_list cannot contain another rich_text_list in its
`elements`. To nest, emit SEPARATE rich_text_list blocks with
increasing `indent` values. Slack renders level 0 as solid `●`,
level 1 as hollow `○`, level 2 as filled square `■`.

```json
[
  {"type":"rich_text_list","style":"bullet","indent":0,"elements":[
    {"type":"rich_text_section","elements":[{"type":"text","text":"parent"}]}
  ]},
  {"type":"rich_text_list","style":"bullet","indent":1,"elements":[
    {"type":"rich_text_section","elements":[{"type":"text","text":"child"}]}
  ]},
  {"type":"rich_text_list","style":"bullet","indent":2,"elements":[
    {"type":"rich_text_section","elements":[{"type":"text","text":"grandchild"}]}
  ]}
]
```

**rich_text_quote** - blockquote, renders with a left border. Same
`elements` shape as rich_text_section.

```json
{"type":"rich_text_quote","elements":[{"type":"text","text":"quoted passage"}]}
```

**rich_text_preformatted** - code block. `elements` is inline (usually a
single `text` element). `border` 0 or 1.

```json
{"type":"rich_text_preformatted","elements":[{"type":"text","text":"go run main.go"}]}
```

##### Inline elements

**text** - with optional `style` for bold/italic/strike/code.

```json
{"type":"text","text":"plain"}
{"type":"text","text":"strong","style":{"bold":true}}
{"type":"text","text":"code","style":{"code":true}}
{"type":"text","text":"both","style":{"bold":true,"italic":true,"strike":true}}
```

**link** - URL with optional anchor text; `style` same as text.

```json
{"type":"link","url":"https://example.com","text":"Example"}
{"type":"link","url":"https://example.com"}
```

**user** - mention, no text content.

```json
{"type":"user","user_id":"U01ABC123"}
```

**usergroup** - group mention.

```json
{"type":"usergroup","usergroup_id":"S01ABC123"}
```

**channel** - channel link mention.

```json
{"type":"channel","channel_id":"C01ABC123"}
```

**emoji** - named emoji. Custom workspace emojis work if they exist.

```json
{"type":"emoji","name":"thumbsup"}
{"type":"emoji","name":"partyparrot"}
```

**date** - server-rendered timestamp. `timestamp` is Unix seconds.
`format` uses tokens like `{date_short}`, `{date_long}`, `{time}`.
`fallback` is what renders if format fails.

```json
{"type":"date","timestamp":1800000000,"format":"{date_short} at {time}","fallback":"soon"}
```

Note: draft previews in Slack Desktop show the fallback, not the formatted
date. The formatted version appears only after the draft is sent. Use a
fallback that reads naturally.

**broadcast** - `@here`, `@channel`, `@everyone`.

```json
{"type":"broadcast","range":"here"}
```

##### Default pattern: one rich_text with sibling containers

Use this for every draft. **One top-level `rich_text` block.**
Inside it, use as many `rich_text_section` /
`rich_text_list` / `rich_text_preformatted` /
`rich_text_quote` containers as you need; they're siblings,
not nested. This is the shape Slack's own compose editor produces.

**The one rule that catches agents out: when a section is directly
followed by a list, preformatted, or quote, the section's last text
inline must end with `\n`** - otherwise the following
container absorbs the heading.

```json
[{"type":"rich_text","elements":[
  {"type":"rich_text_section","elements":[
    {"type":"user","user_id":"U01ABC123"},
    {"type":"text","text":" please review "},
    {"type":"link","url":"https://github.com/org/repo/pull/42","text":"PR #42"},
    {"type":"text","text":". Highlights:\n"}
  ]},
  {"type":"rich_text_list","style":"bullet","indent":0,"elements":[
    {"type":"rich_text_section","elements":[
      {"type":"text","text":"Added "},
      {"type":"text","text":"handleError()","style":{"code":true}},
      {"type":"text","text":" helper"}
    ]},
    {"type":"rich_text_section","elements":[{"type":"text","text":"Dropped legacy JSON path"}]}
  ]},
  {"type":"rich_text_section","elements":[{"type":"text","text":"To run locally:\n"}]},
  {"type":"rich_text_preformatted","elements":[
    {"type":"text","text":"git checkout feat/handler\nmise run test"}
  ]}
]}]
```

The trailing `\n` on `"Highlights:\n"` and
`"To run locally:\n"` is what prevents absorption. Inline
styling (`bold`, `italic`, `link`,
`user`, `channel`, `emoji`, inline
`code`) all work inside sections. List items are themselves
`rich_text_section`s and accept the same inline shapes.

If a heading section ends with a non-text inline (link, emoji, user
mention, channel, broadcast), append a final
`{"type":"text","text":"\n"}` to satisfy the rule;
non-text inlines don't carry the newline themselves.

##### When NOT to use a list

Skip `rich_text_list` if you're representing visual bullets
inside a paragraph rather than real list items. Just write a single
`rich_text_section` with inline `\n` separators and
literal `•` characters. Tradeoff: the `•` markers
are plain text, so the recipient can't indent or reorder them like a
native list - but you avoid the section terminator rule entirely.

##### Tabular data

Tables ARE draftable - the `table` block goes in an **attachment**, not
in top-level `blocks` (where the compose editor strips it). Use a plain
`table`, not `data_table` (the interactive variant is app-only and not
draftable - stripped and tombstoned). Three ways, easiest first:

**1. `--table FILE`** - build a table from a CSV/TSV file. The first
row becomes a bold header (`--no-header` to disable); the delimiter is
auto-detected. The CLI wraps it in an attachment for you:

```
slack draft create '#general' --table report.tsv
```

**2. Attachment passthrough** - for per-cell control (bold, links,
column alignment), pipe an object with the `table` block under
`attachments[].blocks[]`. Cells are `raw_text` (plain) or `rich_text`
(styled); optional `column_settings` set per-column `align` /
`is_wrapped`:

```json
{"blocks":[{"type":"rich_text","elements":[{"type":"rich_text_section","elements":[{"type":"text","text":"Cluster status:"}]}]}],
 "attachments":[{"blocks":[{"type":"table","column_settings":[{},{"align":"right"}],"rows":[
   [{"type":"rich_text","elements":[{"type":"rich_text_section","elements":[{"type":"text","text":"Region","style":{"bold":true}}]}]},
    {"type":"rich_text","elements":[{"type":"rich_text_section","elements":[{"type":"text","text":"Status","style":{"bold":true}}]}]}],
   [{"type":"raw_text","text":"us-east"},{"type":"raw_text","text":"green"}],
   [{"type":"raw_text","text":"us-west"},{"type":"raw_text","text":"degraded"}]
 ]}]}]}
```

A table-only draft is fine - the `blocks` array may be empty; the table
attachment alone survives reconciliation. The table renders in the draft
compose editor as a Table card the human edits and sends.

**3. Inline monospace fallback** - to keep columns inline in the prose
with no attachment, put a monospace ASCII table in a
`rich_text_preformatted` element. It is plain text (not an editable
table) but needs no attachment:

```json
[{"type":"rich_text","elements":[
  {"type":"rich_text_section","elements":[{"type":"text","text":"Cluster status:\n"}]},
  {"type":"rich_text_preformatted","elements":[{"type":"text","text":"Region    Status\n--------  --------\nus-east   green\nus-west   degraded"}]}
]}]
```

Pad the columns with spaces yourself. The heading section ends with
`\n` so the preformatted block doesn't absorb it (the section
terminator rule above).


##### Validation

The CLI checks: non-empty JSON array; every top-level block is a
`rich_text` with a string `type`; at least one has a
non-empty `elements` array; and a `rich_text_section`
directly preceding `rich_text_list`, `rich_text_preformatted`,
or `rich_text_quote` must terminate with a text inline whose
`text` ends with `\n` (trailing empty text inlines
are ignored). All failures emit `invalid_blocks` locally so
Slack never sees the bad shape. Semantic errors inside otherwise-valid
blocks (missing required subfields, unknown inline types, malformed
style objects, a `table` nested in a `rich_text` element) aren't
validated locally - Slack rejects them upstream (the error code
varies, e.g. `invalid_blocks` or `invalid_message`).

### User State

```
slack status get [user...]
slack presence get <user>...
slack dnd info <user>...
```

### Other

```
slack emoji list [--query STR]
slack usergroup list [--include-disabled] [--query STR]
slack usergroup members <group-id>
slack workspace-info info
```

## Workflows

Compose commands to solve typical agent tasks. Use `jq` to thread IDs between steps.

### Find a user, get their recent messages in a channel

```
UID=$(slack user info @alice | jq -r 'select(._meta == null) | .id')
slack message list '#general' --limit 50 | jq -c "select(.user == \"$UID\")"
```

### Find a thread by content and read the whole thread

`search` rows carry a `permalink` - feed it straight to `thread list`, which
resolves it to the parent thread (no channel/ts juggling).

```
PERMA=$(slack search messages "Q3 roadmap in:#general" --limit 1 | jq -r 'select(._meta == null) | .permalink')
slack thread list "$PERMA"
```

### Stage a draft reply to a message you found

```
HIT=$(slack search messages "deploy blocker in:#ext-acme" --limit 1 | jq -c 'select(._meta == null)')
CH=$(echo "$HIT" | jq -r '.channel.id')
TS=$(echo "$HIT" | jq -r '.ts')
cat <<JSON | slack draft create "$CH" --thread "$TS"
[{"type":"rich_text","elements":[{"type":"rich_text_section","elements":[
  {"type":"text","text":"Noted - following up by Friday."}
]}]}]
JSON
```

### Find a 1:1 DM channel with a user

DMs come back with `user` set to the other party's user ID and an
empty `name`. Resolve the user, then match:

```
UID=$(slack user info @alice --fields id | jq -r 'select(._meta == null) | .id')
CH=$(slack channel list --type im --all | jq -r --arg u "$UID" 'select(.user == $u) | .id')
```

### Recover from a `channel_not_found`

When an error has a `hint` field, follow it. Example:

```
slack message list '#ext-acm' 2>&1 >/dev/null | jq -r '.hint'
# → "Run 'slack channel list --query ext-acm' to find ... or '--include-non-member' ..."
slack channel list --query ext-acm
```

## Enrichment

Output automatically includes resolved names alongside IDs:

- `user` fields gain a `user_name` sibling
- `channel` / `channel_id` fields gain a `channel_name` sibling
- `ts` and `*_ts` fields gain a `*_iso` sibling (RFC3339)

Enrichment runs after `--fields`, so `--fields user` keeps the
resolved `user_name` too (no need to list both).

## Pagination

Most list commands return one page by default. Use `--all` to fetch
everything, or use the `next_cursor` from `_meta` with `--cursor`.

## Channel and User Resolution

Prefer URLs (see Inputs at the top of Commands). When you don't have a link,
every channel/user argument also accepts:

- Channels: `C…`/`G…`/`D…` IDs, `#name` or bare `name`, a channel link, or a
  message permalink (resolves to its channel).
- Users: `U…` IDs, emails, `@display-name`, or a profile link.

Channel types (`--type` flag on `slack channel list`):

- `all` - all of the below (default)
- `public` - regular #channels everyone in the workspace can see
- `private` - invitation-only channels
- `mpim` - multi-party DM (group DM with 3+ people)
- `im` - 1:1 DM (`D...` prefix)

User resolution gotchas:

- `@name` matches display name, username, or real name via the local user cache.
- Email lookup (passing `alice@example.com`) goes through Slack's `users.lookupByEmail` API, which fails with session tokens on Enterprise Grid. Prefer `@name` in that case.
- On name collisions, first match wins silently. Inspect `slack user list --query <partial>` to see the candidates.

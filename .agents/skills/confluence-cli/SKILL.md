---
name: confluence-cli
description: "Agent-first Confluence CLI: sync spaces to Markdown, read pages (page list/get/children/ancestors/tree), inspect spaces (space info/list), attachments, CQL search, comments, labels, users, and write content (page create/update/move/delete, attachment upload, comment add including inline, label add/remove) with storage, ADF, or Markdown bodies on stdin"
argument-hint: ""
allowed-tools:
  - Bash(confluence *)
---

# Confluence CLI

Agent-first CLI for Confluence. JSONL output (one JSON object per line). Every
command ends with a `_meta` trailer: `{"_meta":{"has_more":false}}`.

Both reads and writes ship today: `version`, `space sync`, `space info`,
`space list`, `auth`, `page list`, `page get`, `page children`, `page descendants`, `page ancestors`,
`page tree`, `page create`, `page update`, `page move`, `page delete`, `page convert-to-live`,
`attachment list`,
`attachment download`, `attachment upload`, `search`, `comment list`,
`comment add`, `label list`, `label add`, `label remove`, `user current`, and
`user info`. Read commands are below; writes are under "Writing content". The
full command surface is available.

## Prerequisites

Requires the `confluence` binary on PATH. If `command not found`, install it:
`brew install tammersaleh/tap/confluence-cli` (macOS) or
`go install github.com/tammersaleh/confluence-cli/cmd/confluence@latest`.

Skill install/update: `skills add tammersaleh/confluence-cli -g` /
`skills update`.

## Auth

Authenticate with an API token + email over environment variables:

- `CONFLUENCE_SITE` - site base URL (e.g. `https://acme.atlassian.net/wiki`).
- `CONFLUENCE_EMAIL` - Atlassian account email.
- `CONFLUENCE_API_TOKEN` - API token.

`ATLASSIAN_SITE` / `ATLASSIAN_EMAIL` / `ATLASSIAN_TOKEN` work as
compatibility aliases. Or store credentials with `confluence auth login` (see
below); the token is piped on stdin, validated, then saved.

## Commands available now

All honor `--quiet` and `--timeout`.

### auth

Store credentials keyed by canonical site URL. The token is read from stdin,
never argv.

```bash
printf '%s' "$TOKEN" | confluence auth login --site https://acme.atlassian.net --email you@example.com
```

```jsonl
{"status":"logged_in","site":"https://acme.atlassian.net","account_id":"a1"}
{"_meta":{"has_more":false}}
```

`auth status` lists configured sites and any active env override without printing
secrets. `auth logout [<site>]` removes a site; the positional is optional when
only one is configured.

```bash
confluence auth status
confluence auth logout https://acme.atlassian.net
```

### version

```bash
confluence version
```

```jsonl
{"version":"0.1.0"}
{"_meta":{"has_more":false}}
```

### space sync

```bash
confluence space sync <space-url> <output-dir> [--prune] [--dry-run]
```

One-way sync of a Confluence space to local Markdown. Progress goes to stderr;
stdout carries a summary object then the trailer.

- `--prune` - remove local files no longer in the space.
- `--dry-run` - report without writing.
- `--quiet` - suppress all stdout (summary and trailer); rely on the exit code. Progress and warnings still go to stderr.

```bash
confluence space sync https://acme.atlassian.net/wiki/spaces/ENG ./eng-docs
```

```jsonl
{"synced":true,"space":"ENG","output_dir":"./eng-docs","dry_run":false}
{"_meta":{"has_more":false}}
```

Preview before writing:

```bash
confluence space sync https://acme.atlassian.net/wiki/spaces/ENG ./eng-docs --dry-run
```

### space info

Fetch metadata for one or more spaces. Each argument is a space key, a numeric
space id, or a space/page URL; all must be on one site. Each row echoes its
`input`. Unknown keys or unreadable spaces appear inline on stdout and bump
`_meta.error_count`.

```bash
confluence space info ENG
confluence space info ENG DESIGN 98765
```

```jsonl
{"input":"ENG","id":"98765","key":"ENG","name":"Engineering","type":"global","status":"current","homepage_id":"123400"}
{"_meta":{"has_more":false,"error_count":0}}
```

### space list

List spaces on the site (from `--site` or the single stored default; no URL arg).
Page with `--limit`/`--cursor`, or drain with `--all`. Rows carry `id`, `key`,
`name`, `type`, `status`, `homepage_id`.

```bash
confluence space list
confluence space list --all
```

```jsonl
{"id":"98765","key":"ENG","name":"Engineering","type":"global","status":"current","homepage_id":"123400"}
{"_meta":{"has_more":true,"next_cursor":"eyJpZCI6..."}}
```

### page list

List pages in a space. `--space` is a bare key or a space/page URL. Page through
with `--limit`/`--cursor`, or fetch everything with `--all`.

```bash
confluence page list --space ENG
confluence page list --space ENG --limit 50 --cursor eyJpZCI6...
confluence page list --space ENG --all
```

```jsonl
{"id":"123456","title":"API Design","type":"page","space_key":"ENG","parent_id":"123400"}
{"_meta":{"has_more":true,"next_cursor":"eyJpZCI6..."}}
```

### page get

Fetch pages by numeric id or page URL. All arguments must be on one site (one
site per invocation). Each row echoes its `input`.

`--body-format` defaults to `storage`; also `atlas_doc_format` (alias `adf`),
`view`, and `markdown` (alias `md`). ADF `body` is a nested JSON object;
`markdown` is derived from the storage body with attachments resolved to remote
URLs and adds `source_body_format`. Bad ids or unreadable pages appear inline on
stdout and bump `_meta.error_count`.

`--resolve-authors` adds an `author_name` sibling next to `author_id`
(best-effort; one cached user lookup per unique author). A `subtype` field
appears only for live docs (value `live`); use it to confirm a
`page convert-to-live`.

```bash
confluence page get 123456
confluence page get 123456 789012 --body-format markdown
confluence page get https://acme.atlassian.net/wiki/spaces/ENG/pages/123456 --body-format adf
confluence page get 123456 --resolve-authors
```

```jsonl
{"input":"123456","id":"123456","title":"API Design","space_id":"98765","version":5,"author_id":"a1","created_at":"2024-03-01T00:00:00.000Z","created_at_iso":"2024-03-01T00:00:00Z","modified_at":"2024-06-20T14:45:00.000Z","modified_at_iso":"2024-06-20T14:45:00Z","web_url":"https://acme.atlassian.net/wiki/spaces/ENG/pages/123456","body":"# API Design\n\nSee the design.","body_format":"markdown","source_body_format":"storage"}
{"_meta":{"has_more":false,"error_count":0}}
```

### page children

Direct children of a page (numeric id or page URL). Page with
`--limit`/`--cursor`, or drain with `--all`. Rows carry `id`, `title`, `type`.

```bash
confluence page children 123400
confluence page children 123400 --all
```

```jsonl
{"id":"123456","title":"API Design","type":"page"}
{"_meta":{"has_more":true,"next_cursor":"eyJpZCI6..."}}
```

### page descendants

All descendants of a page - every level, not just direct children (numeric id or
page URL). Page with `--limit`/`--cursor`, or drain with `--all`. Rows carry
`id`, `title`, `type`, `depth` (1 for a direct child), and `parent_id` when the
API returns it.

```bash
confluence page descendants 123400
confluence page descendants 123400 --all
```

```jsonl
{"id":"123456","title":"API Design","type":"page","depth":1,"parent_id":"123400"}
{"id":"123999","title":"Auth flow","type":"page","depth":2,"parent_id":"123456"}
{"_meta":{"has_more":true,"next_cursor":"eyJpZCI6..."}}
```

### page ancestors

Ancestor chain of a page, root-most first (numeric id or page URL). Not
paginated. Rows carry `id` and `type`; the endpoint omits `title`.

```bash
confluence page ancestors 123456
```

```jsonl
{"id":"123400","type":"page"}
{"id":"123410","type":"page"}
{"_meta":{"has_more":false}}
```

### page tree

Space page hierarchy in depth-first order. `--space` is a bare key or a
space/page URL. Rows carry `id`, `title`, `type`, `depth` (0 for roots), and
`parent_id` when the page has a parent within the space.

Ordering is by page ID, not Confluence display order - the v2 API doesn't expose
display order in the crawl, so siblings sort by ID for deterministic output.

```bash
confluence page tree --space ENG
```

```jsonl
{"id":"123400","title":"Architecture","type":"page","depth":0}
{"id":"123456","title":"API Design","type":"page","depth":1,"parent_id":"123400"}
{"_meta":{"has_more":false}}
```

### attachment list

List a page's attachments. The argument is a numeric page id or page URL. Rows
carry `id`, `title`, `media_type`, `download_url` (absolute), and `page_id`.

```bash
confluence attachment list 123456
```

```jsonl
{"id":"att987","title":"diagram.png","media_type":"image/png","download_url":"https://acme.atlassian.net/wiki/download/attachments/123456/diagram.png","page_id":"123456"}
{"_meta":{"has_more":false}}
```

### attachment download

Download an attachment by id (not a URL) to a file. Without `--out`, the file is
written to the attachment's filename in the current directory.

```bash
confluence attachment download att987
confluence attachment download att987 --out ./diagram.png
```

```jsonl
{"id":"att987","title":"diagram.png","media_type":"image/png","path":"./diagram.png","bytes":48213}
{"_meta":{"has_more":false}}
```

### search

CQL search. The positional is the CQL query. Site-wide (from `--site` or the
single stored default). Page with `--limit`/`--cursor`, or drain with `--all`.
Rows carry `id`, `title`, `type`, `space_key`, `excerpt`, `url`.

```bash
confluence search 'type = page AND text ~ "runbook"'
confluence search 'label = on-call' --all
```

```jsonl
{"id":"123456","title":"Incident Runbook","type":"page","space_key":"ENG","excerpt":"steps to follow during an incident","url":"https://acme.atlassian.net/wiki/spaces/ENG/pages/123456"}
{"_meta":{"has_more":true,"next_cursor":"eyJpZCI6..."}}
```

### comment list

A page's comments (numeric id or page URL). Footer and inline are fully drained,
so there is no cursor. `--footer`/`--inline` narrow to one kind. Rows carry `id`,
`kind` (`footer`/`inline`), `body`, `author_id`, `created_at`, `web_url`. Inline
rows also carry `resolution_status` (`open`|`reopened`|`resolved`|`dangling`),
`original_selection` (the anchored text), and `inline_marker_ref`; footer rows
omit these. A missing page is a fatal `page_not_found`.

`--resolution-status <status>` filters inline comments by resolution status
(server-side); it implies `--inline` and conflicts with `--footer`. Use it to
find what blocks a body-replacing write:
`comment list <page> --resolution-status open`.

`--replies` recursively drains each comment's reply thread, emitting replies
after their parent with a `parent_id` pointing at the immediate parent (the
filter applies to top-level inline threads; replies under a matching root are
drained unfiltered). `--resolve-authors` adds an `author_name` sibling
(best-effort, cached).

```bash
confluence comment list 123456
confluence comment list 123456 --inline
confluence comment list 123456 --resolution-status open
confluence comment list 123456 --replies
confluence comment list 123456 --resolve-authors
```

```jsonl
{"id":"c1","kind":"footer","body":"<p>Looks good to me.</p>","author_id":"a1","created_at":"2024-06-20T14:45:00.000Z","created_at_iso":"2024-06-20T14:45:00Z","web_url":"https://acme.atlassian.net/wiki/spaces/ENG/pages/123456?focusedCommentId=c1"}
{"id":"c9","kind":"inline","body":"<p>Clarify this.</p>","author_id":"a2","created_at":"2024-06-20T15:00:00.000Z","created_at_iso":"2024-06-20T15:00:00Z","web_url":"https://acme.atlassian.net/wiki/spaces/ENG/pages/123456?focusedCommentId=c9","resolution_status":"open","original_selection":"the retry budget","inline_marker_ref":"m1"}
{"_meta":{"has_more":false}}
```

### label list

A page's labels (numeric id or page URL). Fully drained, so there is no cursor.
Rows carry `id`, `name`, `prefix`.

```bash
confluence label list 123456
```

```jsonl
{"id":"l1","name":"runbook","prefix":"global"}
{"_meta":{"has_more":false}}
```

### user current

The authenticated user. A single row with `account_id`, `display_name`, `email`.

```bash
confluence user current
```

```jsonl
{"account_id":"a1","display_name":"Ada Lovelace","email":"ada@acme.com"}
{"_meta":{"has_more":false}}
```

### user info

Look up users by account id. Each row echoes its `input` and carries
`account_id`, `display_name`, `email`. Unknown ids appear inline on stdout and
bump `_meta.error_count`.

```bash
confluence user info a1
confluence user info a1 a2 a3
```

```jsonl
{"input":"a1","account_id":"a1","display_name":"Ada Lovelace","email":"ada@acme.com"}
{"input":"a2","error":"user_not_found","detail":"No user with account id 'a2'","hint":"confluence user current"}
{"_meta":{"has_more":false,"error_count":1}}
```

## Writing content

Writes that carry content (`page create`, `page update`, `comment add`) take the
body on **stdin**, never as a flag. `--body-format` names the representation of
what you pipe. The body is validated locally before the API sees it; a malformed
body fails with `invalid_body` and nothing is written.

### The body formats

- `storage` - Confluence storage format: a well-formed XHTML fragment, e.g.
  `<p>Hello</p>`. This is what `page get --body-format storage` returns. It
  round-trips cleanly for prose, but NOT for every node: nested task lists
  flatten when written through storage. Prefer it for prose and most authoring;
  use `adf` for rich structure (see below).
- `adf` (alias `atlas_doc_format`) - Atlassian Document Format: a JSON document
  whose root is `{"type":"doc","version":1,"content":[...]}`. Use it when you
  already have ADF (e.g. from `page get --body-format adf`) or need node types
  storage can't express cleanly.
- `markdown` (alias `md`) - GFM Markdown, converted locally to storage XHTML via
  goldmark before the API sees it. Convenient when you're authoring from scratch.
  Fenced code becomes a plain preformatted block, not a Confluence code macro,
  and raw HTML in the Markdown is escaped rather than passed through.

Markdown is supported via `--body-format markdown` (with the code-macro caveat
above). Inline comments are supported via `comment add --inline
--selection-text`.

#### Rich read-modify-write uses ADF

To edit a page that has panels, task lists, statuses, layouts, or macros, fetch
`--body-format adf`, edit the ADF document (the JSONL row's `.body`, a nested
object), and pipe that document back with `--body-format adf`. Do not
reconstruct rich content from derived Markdown or a storage round-trip - both
are lossy. Pipe only the ADF document on stdin, not the whole `page get` row.

Nested checkbox task lists survive only as ADF, and the local validator is
shallow (it will not catch these):

- Every `taskList` and `taskItem` needs a unique `localId`.
- Valid task states are `TODO` and `DONE`.
- A nested `taskList` is a SIBLING of its parent `taskItem`, not inside
  `taskItem.content`.

A no-body `page update` (title-only, or `page move`) preserves the existing body
by re-sending its exact ADF, so it does not flatten these. A `page update` that
pipes a new storage/markdown body replaces the whole body and can.

### Creating a page

Storage body:

```bash
printf '<p>Hello</p>' | confluence page create --space ENG --title "X" --body-format storage
```

ADF body (same page, ADF equivalent):

```bash
printf '{"type":"doc","version":1,"content":[{"type":"paragraph","content":[{"type":"text","text":"Hello"}]}]}' | confluence page create --space ENG --title "X" --body-format adf
```

Markdown body (converted to storage via goldmark):

```bash
printf '# Hello\n\nSome **bold** text.' | confluence page create --space ENG --title "X" --body-format markdown
```

`--body-format` is required only when a non-empty body is piped. With no stdin
(or empty input) the page is created empty and `--body-format` may be omitted.
`--parent <id|url>` nests the page under an existing page on the same site.
`--live` creates a live doc (subtype `live`) instead of a regular page. The
row carries `id`, `title`, `space_id`, `version`, `author_id`, `created_at`,
`web_url` (and `parent_id` when nested, `subtype` when the server returns one);
the body is not echoed.

```jsonl
{"id":"123456","title":"X","space_id":"98765","version":1,"author_id":"a1","created_at":"2024-03-01T00:00:00.000Z","created_at_iso":"2024-03-01T00:00:00Z","web_url":"https://acme.atlassian.net/wiki/spaces/ENG/pages/123456"}
{"_meta":{"has_more":false}}
```

Create a live doc by adding `--live`:

```bash
printf '<p>Hello</p>' | confluence page create --space ENG --title "Team Notes" --body-format storage --live
```

### Bodies that look right but fail

These pass a casual eye but are rejected locally as `invalid_body`:

- Storage that isn't well-formed XML - an unclosed or mismatched tag:
  `<p>hi` or `<b><i>hi</b></i>`. Every tag must close and nest correctly
  (HTML void elements like `<br>` may self-close). Do not wrap the fragment in
  `<?xml ...?>`, `<!doctype>`, `<html>`, or `<body>`.
- ADF that is a top-level array instead of a doc object:
  `[{"type":"paragraph",...}]`. The root must be `{"type":"doc","version":1,...}`.
- ADF missing the numeric `version`:
  `{"type":"doc","content":[]}`.
- An ADF text node without a `text` string:
  `{"type":"text"}` inside `content`. A text node must be
  `{"type":"text","text":"..."}`.

A correct minimal ADF doc:

```json
{"type":"doc","version":1,"content":[{"type":"paragraph","content":[{"type":"text","text":"Hello"}]}]}
```

### Updating a page (optimistic concurrency)

`page update` requires `--if-version <n>`, the version you expect to be current.
If the live version differs, the command fails with a recoverable
`version_conflict` and writes nothing; on success the page is written at `n+1`.
A concurrent edit landing between the preflight read and the write also returns
`version_conflict`, not a generic error. Omitting `--title` preserves the title;
omitting the piped body preserves the body as its exact ADF (not a lossy storage
round-trip).

Passing neither `--title` nor a body is rejected with `invalid_input`. A
title-only update whose title equals the current title is a no-op: it returns
`updated:false` with the version unchanged and issues no write. A real write
returns `updated:true`.

The safe pattern is get, then update with the observed version:

```bash
version=$(confluence page get 123456 --fields version | head -1 | jq .version)
printf '<p>Revised.</p>' | confluence page update 123456 --if-version "$version" --body-format storage
```

```jsonl
{"id":"123456","title":"X","version":6,"previous_version":5,"updated":true,"web_url":"https://acme.atlassian.net/wiki/spaces/ENG/pages/123456"}
{"_meta":{"has_more":false}}
```

On a conflict, re-fetch and retry with the new version:

```json
{"error":"version_conflict","detail":"expected current version 5, got 7","hint":"Fetch the latest with 'confluence page get 123456' and retry with --if-version 7","input":"123456"}
```

#### Inline-comment safety

A `page update` that pipes a NEW body can destroy the anchors of open inline
comments (they are markers inside the body). So a body-piped `page update`
refuses to write when the page has any inline comment that is not `resolved` -
`open`, `reopened`, `dangling`, and any unknown status all block. The refusal is
`unresolved_inline_comments`; it lists the blocking comments (id,
`resolution_status`, `original_selection`, `inline_marker_ref`, `web_url`) in the
error's `data` object, writes nothing, and does not bump the version.

A title-only `page update` and `page move` re-send the page's exact ADF, which
preserves inline-comment anchors (verified against a live page), so they are not
guarded. Only a piped replacement body triggers the guard.

Inspect first with `comment list <page> --inline`; resolve or re-anchor the
comments in Confluence, then retry. `--allow-unresolved-inline-comments`
overrides the guard (it skips the inspection entirely); use it only when you
accept possible anchor loss. The override does not bypass `--if-version` or any
other check. If the comment inspection itself fails, the write is refused
(fail-closed).

```json
{"error":"unresolved_inline_comments","detail":"refusing to replace the page body: 1 inline comment(s) are not resolved and this write may destroy their anchors","hint":"Resolve or re-anchor the comments in Confluence (see the web URLs), then retry. Pass --allow-unresolved-inline-comments to override.","input":"123456","data":{"page_id":"123456","blocking_comment_count":1,"blocking_comments":[{"id":"c9","resolution_status":"open","original_selection":"the retry budget","inline_marker_ref":"m1","web_url":"https://acme.atlassian.net/wiki/spaces/ENG/pages/123456?focusedCommentId=c9"}]}}
```

### Moving a page (reparent within a space)

`page move <page-ref> --parent <dest-ref> --if-version <n>` reparents a page
under a different parent in the SAME space, preserving the page ID, history,
comments, and attachments. Page IDs are stable across renames and moves; titles
are not, so cite pages by ID.

The Confluence v2 API cannot move a page across spaces (the personal-draft to
team-space publication step). A cross-space destination is refused with
`cross_space_move_unsupported`; do that move in the Confluence UI. `page move`
also refuses self-parenting and cycles (`invalid_move`), and enforces
`--if-version`. If the page is already under the destination, it returns
`moved:false` with no write. It re-sends the exact ADF, so it does not touch
inline-comment anchors and is not subject to the inline-comment guard.

```bash
confluence page move 123456 --parent 200000 --if-version "$version"
```

```jsonl
{"id":"123456","title":"X","space_id":"98765","previous_parent_id":"100000","parent_id":"200000","previous_version":5,"version":6,"moved":true,"web_url":"https://acme.atlassian.net/wiki/spaces/ENG/pages/123456"}
{"_meta":{"has_more":false}}
```

### Deleting a page

`page delete` moves pages to the **trash** (`delete_mode:"trash"`), not a
permanent purge. A real delete requires `--yes`; without it (and without
`--dry-run`) the command refuses with `confirmation_required` and deletes
nothing. Preview first with `--dry-run`:

```bash
confluence page delete 123456 --dry-run
confluence page delete 123456 --yes
```

```jsonl
{"input":"123456","id":"123456","deleted":true,"delete_mode":"trash"}
{"_meta":{"has_more":false,"error_count":0}}
```

### Converting a page to a live doc

`page convert-to-live <id|url>...` converts existing pages to live docs. There is
no public Confluence API for this. The command calls Confluence's undocumented
internal `/cgraphql` endpoint, which is unsupported: it may change or be removed
without notice, it is reportedly blocked from Atlassian's automation IP ranges
(it works with API-token auth from a developer machine), and there is no
supported API to convert back. A warning is written to stderr before the first
conversion (suppress it with `--quiet`). All arguments must be on one site.

Rows echo `input` and carry `id` and `converted:true`. `converted:true` means
the mutation reported success; the command does not read the page back. Confirm
the result with `page get` and check `subtype`. Per-item failures appear inline
as `live_convert_failed` and bump `_meta.error_count`; 401/403/404 keep their
normal codes.

```bash
confluence page convert-to-live 123456
confluence page get 123456 --fields subtype   # verify: {"subtype":"live"}
```

```jsonl
{"input":"123456","id":"123456","converted":true}
{"_meta":{"has_more":false,"error_count":0}}
```

To create a live doc from scratch, prefer `page create --live` (a supported REST
call) over creating a page and converting it.

### Uploading attachments

`attachment upload` sends local files as multipart uploads. Each file is
independent; a per-file failure is reported inline and does not abort the rest.
Re-uploading a file whose name matches an existing attachment creates a **new
version** of it rather than a duplicate.

```bash
confluence attachment upload 123456 ./diagram.png ./notes.pdf
```

```jsonl
{"input":"./diagram.png","page_id":"123456","attachment_id":"att987","title":"diagram.png","media_type":"image/png","uploaded":true}
{"_meta":{"has_more":false,"error_count":0}}
```

### Adding comments and labels

`comment add` writes a comment; the body is read from stdin and `--body-format`
is required (`storage`, `adf`, or `markdown`). Without `--inline` it is a footer
comment. The row's `body_format` is the API representation (`storage` or
`atlas_doc_format`).

```bash
printf '<p>Looks good to me.</p>' | confluence comment add 123456 --body-format storage
```

`--inline` anchors the comment to on-page text with `--selection-text <text>`.
When the text occurs more than once, `--match-index N` (0-based) picks the
occurrence and `--match-count N` asserts the expected number of occurrences.
Inline rows carry `kind:"inline"` and `selection_text`.

```bash
printf '<p>Clarify this.</p>' | confluence comment add 123456 --inline --selection-text "the retry budget" --body-format storage
```

```jsonl
{"id":"c2","page_id":"123456","kind":"inline","selection_text":"the retry budget","body_format":"storage","web_url":"https://acme.atlassian.net/wiki/spaces/ENG/pages/123456?focusedCommentId=c2"}
{"_meta":{"has_more":false}}
```

`label add`/`label remove` take one or more labels; each is applied
independently with inline per-label errors.

```bash
confluence label add 123456 runbook on-call
confluence label remove 123456 on-call
```

```jsonl
{"page_id":"123456","name":"runbook","prefix":"global","added":true}
{"_meta":{"has_more":false,"error_count":0}}
```

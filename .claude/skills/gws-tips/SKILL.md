---
name: gws-tips
description: "Tips, gotchas, and recipes for the gws CLI (googleworkspace/cli). Read before running any gws command. Grammar is `gws <service> <resource> <method> --params '{JSON}'`; every API argument (fileId, documentId, spreadsheetId, calendarId, range, fields, q) goes inside `--params`, NOT as a flag like `--fileId`. Discover params with `gws schema <service.resource.method>`, not `--help`. Also covers Doc comment anchored text, stray download files, and other API quirks. Triggers on any use of `gws drive`, `gws docs`, `gws sheets`, `gws gmail`, `gws calendar`, or related Google Workspace CLI invocations."
---

# gws CLI Tips and Gotchas

The auto-generated `gws-shared`, `gws-drive`, `gws-docs`, etc. skills are
overwritten by `gws generate-skills`. This skill is the durable place
for hand-curated knowledge.

## Argument model: everything goes in `--params`

The grammar is `gws <service> <resource> [sub-resource] <method> [flags]`.
There are no per-item named flags. `--fileId`, `--documentId`,
`--spreadsheetId`, `--calendarId`, `--range`, `--fields`, `--query`/`--q` do
not exist as flags - every API argument goes inside a single `--params '{JSON}'`
object. Request bodies for writes go in `--json '{JSON}'`. `--params` takes one
object and cannot be repeated.

This is the most common mistake: reaching for `gws drive files export --fileId X`
(Web-API/flag habit) instead of `--params '{"fileId":"X"}'`. The CLI rejects the
flag with `unexpected argument '--X' found`.

Discover a method's parameters with `gws schema <service.resource.method>` - not
`<cmd> --help`, which doesn't exist per-command.

```bash
gws schema drive.files.export        # shows fileId, mimeType, etc.
```

Correct forms for the commands that trip up most often:

```bash
gws drive files export --params '{"fileId":"<ID>","mimeType":"text/markdown"}' --output out.md
gws drive files list   --params '{"q":"name contains \"foo\"","fields":"files(id,name)"}'
gws calendar events list --params '{"calendarId":"primary","timeMin":"2026-07-01T00:00:00Z"}'
gws sheets spreadsheets get --params '{"spreadsheetId":"<ID>"}'
gws sheets spreadsheets values get --params '{"spreadsheetId":"<ID>","range":"A1:Z100"}'
gws docs documents get --params '{"documentId":"<ID>"}'
```

Note `sheets spreadsheets values get`, not `sheets values get` - the latter
errors with `unrecognized subcommand 'values'`. `--output` paths must resolve
inside the working directory; an absolute `/tmp/...` path is rejected as outside
the allowed root.

## Drive comments: getting the anchored text

`gws drive comments list` requires a `fields` parameter. The API
silently omits any field you don't list. To get the text each comment
is anchored to, request `quotedFileContent` explicitly - Google
populates it automatically for UI-created comments. Do not export the
doc to `.docx`/`.html` to recover anchor text; it's unnecessary.

```bash
gws drive comments list --params '{
  "fileId": "<DOC_ID>",
  "includeDeleted": true,
  "fields": "comments(id,anchor,quotedFileContent/value,content,resolved,author/displayName,createdTime,modifiedTime,replies(content,author/displayName,createdTime,action))"
}'
```

`quotedFileContent.value` is HTML-encoded (`doesn&#39;t`). Decode entities
before display.

UI-created comment `anchor` values are opaque `kix.<id>` strings. They
do not appear anywhere in `docs.documents.get` output, so there's no
way to resolve them to a body position. Rely on `quotedFileContent`
for the text content.

API-created comments support a documented offset format:

```json
{"r":"head","a":[{"txt":{"o":<offset>,"l":<length>,"ml":<max>}}]}
```

`o` is 0-based from the start of the doc body. The Docs API uses
1-based indexing for the same content, so `body_index = anchor_offset + 1`.

## `fields` parameter is required on most read methods

Many Drive API read methods (`comments.list`, `comments.get`,
`about.get`, etc.) return HTTP 400 without `fields`. Always supply it,
and remember to include every property you want back - including nested
ones via dot/parenthesis syntax (`replies(content,author/displayName)`).

## Stray `download.<ext>` files

Some commands write a 0-byte or partial `download.<ext>` file in the
working directory on success, regardless of whether the operation
returns binary content. Known offenders:

- `gws drive files delete` (writes `download.html`)
- `gws drive files export` (writes `download.bin` or similar)

Clean these up after use. Prior cleanup commit in cw repo: `b056430`.

## zsh `!` expansion in sheet ranges

Sheet ranges like `Sheet1!A1` need double quotes (or escaping) because
zsh treats `!` as history expansion. Single quotes alone are fine for
the `--params`/`--json` JSON payloads, but inline shell args with `!`
must be double-quoted. (Also documented in the auto-generated
`gws-shared/SKILL.md`.)

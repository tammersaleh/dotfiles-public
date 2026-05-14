---
name: confluence-editing
description: "Read, create, and update Confluence pages via the `mcp__atlassian__*` tools. Load before calling `createConfluencePage`, `updateConfluencePage`, `createConfluenceFooterComment`, `createConfluenceInlineComment`, or any time you're about to write Confluence content. Covers the ADF nested task-list gotcha, the inline-comment destruction rule, and what content format to use when fetching vs writing."
---

# Confluence Editing

Load this skill before calling any `mcp__atlassian__*` Confluence write tool
(`createConfluencePage`, `updateConfluencePage`,
`createConfluenceFooterComment`, `createConfluenceInlineComment`). Also load
when reading Confluence content if you'll later modify it - the read format
matters.

## Never update a page with active inline comments

`updateConfluencePage` replaces the entire page body. The new body has no
relationship to the old anchor offsets, so every active inline comment loses
its anchor and is destroyed.

If the page has any unresolved inline comments, do not call
`updateConfluencePage`. Instead, produce a list of changes with the
permalink to each comment and the replacement text, and hand it to the
human to apply in the editor.

Check before writing:

```
mcp__atlassian__getConfluencePageInlineComments(pageId: "...")
```

If any returned comment has `state: "open"` (unresolved), refuse the update
and surface the diff for manual application instead.

## Nested task lists: use ADF, not HTML

Confluence's HTML/storage format silently mangles nested checkbox task
lists on write. The only reliable path is `contentFormat: "adf"` with a
properly structured ADF document.

What does NOT work:

- HTML format (`contentFormat: "html"`) with the nested
  `<ul data-type="task-list">` as a **sibling** of the parent `<li>`
  (the shape Confluence's read API returns). The children get silently
  stripped on write.
- HTML format with the nested `<ul>` placed **inside** the parent
  `<li>`. The children's text gets concatenated into the parent's text
  content, flattening the structure.

What does work:

- `contentFormat: "adf"` with the nested `taskList` as a **sibling** of
  its parent `taskItem`, both inside the outer `taskList`'s `content`
  array. This is the shape the Confluence editor produces natively.

### Minimal working ADF snippet

Parent task with two child sub-tasks (copy-paste-modify):

```json
{
  "version": 1,
  "type": "doc",
  "content": [
    {
      "type": "taskList",
      "attrs": {"localId": "outer-list"},
      "content": [
        {
          "type": "taskItem",
          "attrs": {"localId": "parent-1", "state": "TODO"},
          "content": [{"type": "text", "text": "Parent task"}]
        },
        {
          "type": "taskList",
          "attrs": {"localId": "nested-list"},
          "content": [
            {
              "type": "taskItem",
              "attrs": {"localId": "child-1", "state": "TODO"},
              "content": [{"type": "text", "text": "Child task A"}]
            },
            {
              "type": "taskItem",
              "attrs": {"localId": "child-2", "state": "DONE"},
              "content": [{"type": "text", "text": "Child task B"}]
            }
          ]
        }
      ]
    }
  ]
}
```

Notes:

- Every `taskList` and `taskItem` needs a unique `localId`. Generate
  short stable strings; Confluence will rewrite them server-side but
  rejects collisions.
- `state` is `"TODO"` or `"DONE"`.
- Pass the whole document as a JSON string to the `body` parameter
  alongside `contentFormat: "adf"`.
- The nested `taskList` is a sibling of the parent `taskItem` inside
  the same outer `taskList.content`. Do not put it inside the parent
  `taskItem.content`.

## Content formats: which to use when

- **Reading to render for a human**: `markdown` is fine, but it's lossy
  for nested task lists, status badges, panels, and other macros.
- **Reading to modify and write back**: fetch as `adf`. Both `markdown`
  and `html` lose structural detail (especially nested task lists). The
  ADF you get back is the authoritative shape and is what the write API
  accepts.
- **Writing**: prefer `adf` for anything with task lists, panels, info
  macros, status badges, layouts, or other Confluence-specific
  structures. Use `storage` (XHTML) only when you have a known-good
  storage string (e.g. pandoc output for a flat document with no
  Confluence macros).
- **Markdown on write**: Atlassian accepts it, but it round-trips
  through their converter and loses anything that isn't plain CommonMark.
  Do not use for anything richer than paragraphs, lists, headings, and
  code blocks.

## Tooling reminders

- `updateConfluencePage`'s `body` parameter is large. ~70KB of ADF has
  been observed working in a single call. If you hit a size limit,
  split the page or strip unused whitespace from the JSON.
- Large ADF responses get persisted to the tool-results file rather
  than inlined in the transcript. Process them with `jq` from the
  Bash tool when they don't fit inline.
- Page IDs are stable across renames; titles are not. Cite pages by
  ID in KB notes.
- `getConfluencePage` returns the current version number. Pass it back
  on update; Atlassian rejects writes that don't increment it.
- The Atlassian MCP server occasionally disconnects. If MCP tools fail,
  the v2 REST API (`POST /wiki/api/v2/pages`, `PUT /wiki/api/v2/pages/{id}`)
  works directly with an API token. For storage-format pages, pandoc
  can convert markdown to XHTML; for anything with macros or nested
  task lists, build the ADF by hand.

## When `mcp__atlassian__*` tools aren't loaded

These tools are deferred. Load them via ToolSearch before the first
call. Common starting set:

```
ToolSearch(query: "select:mcp__atlassian__getConfluencePage,mcp__atlassian__updateConfluencePage,mcp__atlassian__createConfluencePage,mcp__atlassian__getConfluencePageInlineComments")
```

Add `createConfluenceInlineComment`, `createConfluenceFooterComment`,
`getConfluenceSpaces`, `searchConfluenceUsingCql`, or others as needed.

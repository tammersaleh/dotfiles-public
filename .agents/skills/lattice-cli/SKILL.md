---
name: lattice-cli
description: "Read feedback from Lattice: feedback given and received for you and your direct reports, feedback requests, and user lookup. Load this BEFORE running any `lattice` command - the CLI has its own grammar (`lattice feedback list --team`, `lattice request list`), not Lattice API paths."
argument-hint: ""
allowed-tools:
  - Bash(lattice *)
---

# Lattice CLI

Read-only CLI over Lattice's internal GraphQL API. JSONL output: one JSON
object per line, then a `_meta` trailer, always present:
`{"_meta":{"has_more":false}}`. A trailer carrying an `error` field means the
rows above it are incomplete. Fatal errors are one JSON object on stderr with
`error`, `detail`, and `hint`.

Requires the `lattice` binary on PATH and a stored session. On
`error: not_authed` (exit 2), tell the user to run
`lattice auth login --chrome` in their own terminal; it prompts for the
macOS keychain and must not be run by an agent.

## Commands

| Task | Command |
|---|---|
| Everything visible to me, for me and every direct report | `lattice feedback list --team` |
| My own feed, one page | `lattice feedback list` |
| One report's feed, all pages | `lattice feedback list --user <id-or-email> --all` |
| Only feedback the feed user received / gave | `--direction received` / `--direction given` |
| Since a date | `--since 2026-09-01` (client-side filter; still walks pages) |
| One record by global id | `lattice feedback get <global_id>...` |
| Requests asking me to write feedback | `lattice request list [--pending] [--all]` |
| Requests I made of others | `lattice request list --submitted [--pending] [--all]` |
| Who am I / my reports / resolve ids or emails | `lattice user me`, `lattice user reports`, `lattice user info <id-or-email>...` |
| Session state without network | `lattice auth status` |

`--user` and `user info` accept a Lattice entity id (UUID) or the email of
yourself or a direct report. Lattice has no company-wide email lookup.

Global flags: `--fields id,visibility,author` projects rows (a missing field
comes back as `null`); `--limit` (1-100), `--cursor`, `--all` page; `--quiet`;
`--timeout 2m`; `--trace` writes per-request diagnostics to stderr.

## Feedback row

```json
{"id":"<entity uuid>","global_id":"<relay id>","type":"feedback",
 "created_at":"2026-09-22T02:16:48.412Z","body":"<html>",
 "visibility":"privateAndManager",
 "visibility_note":"author, recipient, and the recipient's manager",
 "author":{"id":"...","name":"...","email":"...","title":"..."},
 "targets":[{"id":"...","name":"...","email":"...","title":"..."}],
 "requested":true,
 "request":{"id":"...","global_id":"...","created_at":"...","requestor":{...},"writer":{...},"body":"...","visibility":"..."},
 "company_values":["..."],"competency":null,"growth_area":null,
 "acknowledgment_state":"NOT_REQUIRED","acknowledgment_note":null,"acknowledgments":[],"reactions":[],
 "feed_user":{"id":"...","name":"...","email":"...","title":"..."}}
```

`visibility` values: `public` (everyone), `private` (author and recipient),
`managerOnly` (author and the recipient's manager; the recipient cannot see
it), `privateAndManager` (author, recipient, and the recipient's manager).
Lattice does not expose who has read a piece of feedback; `acknowledgments`
is the closest signal. `requested` with `request.requestor` says who asked
for it. `feed_user` is the user whose feed produced the row; with `--team` a
row appears once, under the first feed it was seen in.

Request rows have `type: "feedback_request"`, `fulfilled_at`, `pending`,
`requestor` (who asked), `writer` (who is asked to write), and `subject`
(who it is about).

## Exit codes

`0` success, `1` general or partial failure (per-item errors are inline rows
with `error` and `input`, counted in `_meta.error_count`), `2` auth,
`3` rate limited after retries (Cloudflare throttles bursts; wait a minute),
`4` network.

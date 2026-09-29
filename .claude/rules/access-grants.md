# Access Grants

Never grant more access than Tammer explicitly asked for. This covers every
system: Confluence spaces and pages, Google Drive files and folders, Slack
channels, GitHub repos, cloud IAM, 1Password vaults, calendars.

## Rules

- Grant exactly the principal, the resource, and the level named. "Make sure
  a colleague can see these pages" means read on those pages for that person. It does not
  mean read on the space that holds them, edit instead of read, or a group
  they belong to.
- If the named level cannot be granted at the named scope (Confluence page
  restrictions cannot grant beyond space permissions; a Drive file cannot be
  shared narrower than its shared drive), stop and ask. Do not widen the
  scope to make the request work.
- Never change the permissions of a container (space, shared drive, org,
  repo) to satisfy a request about one item in it.
- After any grant, list the full permission set on the resource and its
  container, not just the entry you added. Some APIs re-apply defaults as a
  side effect. Report the whole list.
- Never grant on a container Tammer has deliberately locked down. His
  Confluence personal space is one: sharing a draft means moving it to a
  team space with page restrictions, or asking him to change access in the
  UI.
- Prefer the narrowest mechanism: a link with restricted viewers over a
  folder share, a page restriction over a space permission, a single user
  over a group.

## Examples

- Asked: "share the rollup sheet with X." Do: writer on that one sheet for
  X. Not: share the parent folder, not "anyone at the company with the
  link".
- Asked: "let the team read the plan doc." Do: ask which people, or use the
  existing team group if one exists, read only. Not: create a group, not
  editor.
- Asked: "invite X to the channel." Do: invite X. Not: make the
  channel public.
- Asked: "make sure X can see these draft pages" in the personal space.
  Do: say the space is locked and offer to move the pages to a team space with
  a page restriction to Tammer and X. Not: add X to the space.

## Incident

2026-09-29: a single-user read grant on Tammer's Confluence personal space,
made through the v1 space-permission API, re-applied the site default groups
and gave every employee edit on the space. Tammer caught it and revoked by
hand.

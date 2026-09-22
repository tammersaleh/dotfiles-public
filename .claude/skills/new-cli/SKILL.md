---
name: new-cli
description: Scaffold a new agent-first Go CLI repo the way slack-cli, confluence-cli, and lattice-cli are built - GitHub repo, shared CLAUDE.md conventions, SPEC.md, mise/golangci/GoReleaser/release-please, CI, RELEASE_PAT from 1Password, Brewfile and global-rule wiring. Triggers on "new CLI", "create a CLI repo", "scaffold a CLI", "stub repository for a CLI", "make a tool like slack-cli", "start a new cli for X".
---

# New CLI

Creates a stub repo under `~/src/github.com/tammersaleh/<name>-cli` that
matches the sibling CLIs, so the next session can start on SPEC.md instead of
plumbing. Reference implementations are living repos, not templates embedded
here: read them and copy from them.

- `~/src/github.com/tammersaleh/slack-cli` - public, cask distribution, the
  fullest CLAUDE.md (workflow, release versioning, autonomy, todo style).
- `~/src/github.com/tammersaleh/confluence-cli` - public, golangci v2 config,
  terser CLAUDE.md, HTTPS-push notes.
- `~/src/github.com/tammersaleh/lattice-cli` - private, formula distribution,
  privacy section for personnel data. The model for any private CLI.

Naming: repo and Go module are `<name>-cli`; the binary is `<name>`.

## 1. Ask

Use `AskUserQuestion` once, with everything on it:

1. Public or private repo. This drives distribution, the privacy section, and
   the GoReleaser config. Do not guess.
2. Binary name (defaults to the system it wraps, lowercase).
3. One line on what it does and which system it talks to.
4. Read-only, or does it need writes? Default read-only; a write surface is a
   SPEC.md decision.

Anything else (auth model, API surface) is an open question for SPEC.md, not
something to settle now.

## 2. Create the repo

```bash
cd ~/src/github.com/tammersaleh && gh repo create tammersaleh/<name>-cli --public|--private --description "<one line>" --clone
```

## 3. Copy the scaffolding

From the siblings, verbatim unless noted:

- `.githooks/pre-push` (runs `mise run check`), then
  `git config core.hooksPath .githooks`.
- `.github/workflows/ci.yml` and `release.yml` from slack-cli. In `ci.yml`, the
  tidy check must be `git diff --exit-code -- go.mod go.sum`; without `--` a
  dependency-free module (no `go.sum`) fails with exit 128.
- `.golangci.yml` from confluence-cli (v2; v1 emits false positives on Go 1.25).
- `mise.toml` from lattice-cli, binary name swapped. `check` = test + lint +
  build.
- `release-please-config.json` from any sibling; `.release-please-manifest.json`
  as `{ ".": "0.0.0" }`.
- `.gitignore` from lattice-cli: binary, Go, IDE, `CLAUDE.local.md`, and
  `/bugs/` `/todo/` ignored (not just untracked).
- `LICENSE` (MIT), `KNOWN_ISSUES.md` ("None.").
- `.goreleaser.yml`: from slack-cli for public (keep `homebrew_casks`, swap
  names, description, `ldflags` module path). From lattice-cli for private (no
  `homebrew_casks`; see step 5).
- `go.mod` (`module github.com/tammersaleh/<name>-cli`, `go 1.25`) and a
  placeholder `cmd/<name>/main.go` that prints "not implemented yet". No Kong,
  no real code. It exists so `mise run check`, CI, and the GoReleaser snapshot
  build are green from commit one.
- `skills/<name>-cli/SKILL.md` stub with the frontmatter shape of the sibling
  skills (`allowed-tools: Bash(<name> *)`) and the JSONL/`_meta` contract.
- `todo/README.md` (ignored, local only) in the house style: one concern per
  file, written for a cold session, verbatim commands and output, delete when
  landed.

## 4. Write CLAUDE.md, SPEC.md, README.md

Start from lattice-cli's `CLAUDE.md` and adapt. Sections every CLI carries:
intro (binary vs repo naming, JSONL, Kong, pointer to siblings), Status (stub),
Design constraint (read-only unless told otherwise), Output and error contract
with exit codes (0/1/2 auth/3 rate limit/4 network), Workflow (the ten steps:
SPEC first, branch, red-green, `mise run check`, conventional commits,
mandatory `feature-dev:code-reviewer` before push with a re-run after fixes,
push with hook, not done until installed and verified, retrospective, next),
Bug reports and todos, Release versioning (commit type is the release trigger;
never ask about version numbers), Distribution, Autonomy, Testing, Git (no PRs,
HTTPS push via gh credential helper, workflow files need SSH), Sandbox, target
Project structure.

Private repos add the privacy section: identifiers allowed, credentials never,
content from the wrapped system never if it is personal data, no org charts, a
grep to run before committing. Public repos instead carry slack-cli's "never
commit real workspace data" section with the synthetic conventions
(`C01ABC`, `U01XYZ`, Alice Adams, `acme.example.com`).

`SPEC.md`: design principles, output model with examples, global flags,
target command surface, a `## Decisions` list (dated) and `## Open questions`
to settle before the first `feat:`.

`README.md`: install, agent skill (`skills add tammersaleh/<name>-cli -g`),
development (`mise run setup-hooks`, `mise run check`).

## 5. Distribution

Public: Homebrew cask via GoReleaser into `tammersaleh/homebrew-tap`
(`Casks/<name>-cli.rb`). Copy slack-cli's `homebrew_casks` block.

Private: a cask cannot download private release assets, and an `Authorization`
header breaks on GitHub's S3 redirect. Use a source-build FORMULA in the public
tap (`Formula/<name>-cli.rb`) with a git URL and `tag:`/`revision:`; Homebrew
clones over HTTPS through the gh credential helper. GoReleaser cannot template
that, so the release workflow needs a step that rewrites the formula in the tap
with `RELEASE_PAT` and pushes. Copy that step from lattice-cli's `release.yml`
if it exists there yet; otherwise write it and record it in both repos'
CLAUDE.md. Formula shape is in lattice-cli's CLAUDE.md "Distribution".

Either way, add the line to `~/dotfiles/public/packages/Brewfile` per that
directory's README, then commit and push dotfiles with a scoped pathspec.

## 6. First commit and push

`mise trust && mise install`, then `mise run check` and gate on its exit code
(never pipe it through `grep`). Commit as `chore: scaffold ...` so nothing
releases. Push over SSH the first time: workflow files need the `workflow`
scope, which the gh token lacks, and the initial push always includes them.

## 7. RELEASE_PAT

release-please and the auto-merge step need a user-attributed PAT. It is the
"Github Release Automation Token" item in the personal 1Password vault, shared
by every CLI. Say a Touch ID prompt is coming, then one Bash call:

```bash
op item get "Github Release Automation Token" --account my.1password.com --vault Private --format json > /tmp/op-item.json
val=$(jq -r '[.fields[] | select(.type=="CONCEALED" and (.value // "") != "")] | .[0].value' /tmp/op-item.json); rm -f /tmp/op-item.json
[ -n "$val" ] && [ "$val" != "null" ] || { echo "empty value"; exit 1; }
printf '%s' "$val" | gh secret set RELEASE_PAT --repo tammersaleh/<name>-cli && echo "set len=${#val}"
```

`--account` is mandatory: two accounts are signed in and an unscoped `op item
get` returns nothing. `gh secret set` accepts empty stdin silently and the
release workflow then fails with `Input required and not supplied: token`, so
check the length before piping. If `op` reports `authorization timeout`, the
prompt was missed; run the same command again.

## 8. Verify CI and release

```bash
gh run list --limit 5 --json name,status,conclusion --jq '.[] | "\(.name): \(.status) \(.conclusion)"'
```

CI must be green. The release run fails until `RELEASE_PAT` exists; rerun it
with `gh run rerun <id>` after step 7 and confirm success. A `chore:`-only
history opens no release PR; that is correct.

## 9. Wire the global rule

Add `- \`<name>\` -> \`~/src/github.com/tammersaleh/<name>-cli/todo/\`` to the
"My CLIs: file issues" list in `~/.claude/CLAUDE.md` (a symlink into
`~/dotfiles/public`). Commit with `docs(claude): ...` scoped to that file and
push. The dotfiles repo is public; the repo name is fine, the employer is not.

## 10. Report

State the repo path and URL, what is decided versus open in SPEC.md, and that
the next session starts in the new repo on SPEC.md's open questions. Nothing
should be left for the user except decisions only they can make.

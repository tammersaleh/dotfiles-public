---
name: dotfiles-manager
description: "Manage dotfiles with dfm: symlink the public and private dotfiles repos into $HOME (stow-compatible), adopt a file into a repo, ignore a path, pull both repos, report status. Load this BEFORE running any `dfm` command, and whenever a task touches ~/dotfiles, stow, or a symlink in $HOME that points into ~/dotfiles."
argument-hint: ""
allowed-tools:
  - Bash(dfm *)
---

# dfm

Replaces the `dotfiles` bash script and GNU Stow. Two packages, `public` then
`private`, under the root (`~/dotfiles`) are symlinked into the target
(`$HOME`) with stow's folding semantics. Human progress on stderr by default;
`--json` gives JSONL on stdout, one object per action, then a `_meta`
trailer, always present: `{"_meta":{"has_more":false}}`. Zero counters are
omitted from `_meta`.

Requires `dfm` on PATH. If `command not found`:
`brew install --cask tammersaleh/tap/dotfiles-manager`.

## Safety rules

- Run `dfm status` first. It is the read-only probe: never fetches, never
  writes, and shows every conflict and broken link the next `install` would
  hit.
- Run `install`, `pull`, `public`, and `private` with `--dry-run` before the
  real run. Read the plan. Under `--dry-run` nothing on disk changes.
- Know the root and target before running anything. Defaults are `~/dotfiles`
  and `$HOME`; `--root`/`--target` (or `DFM_ROOT`/`DFM_TARGET`) override them.
  Never point them at a tree you did not mean to change.
- A `conflict` (exit 2) means stop and report. Nothing was changed. Do not
  delete or move the conflicting path on your own; the hint names the two
  choices (`dfm public <path>` to adopt it, or remove it) and the human picks.
- `dirty_tree` on `pull` means uncommitted changes in a package. Do not
  commit, stash, or discard them yourself; report which package.
- Edit managed files where they live in the package, not by replacing the
  symlink in the target.

## Grammar

```
dfm install
dfm status
dfm public <path>
dfm private <path>
dfm ignore <path>
dfm pull [--no-hooks]
dfm version
```

Global flags go before or after the command: `--root DIR`, `--target DIR`,
`--dry-run`, `--json`, `--verbose`, `--quiet`. `--no-hooks` must follow
`pull`. `--verbose` wins over `--quiet`; `--json` also suppresses progress.

`<path>` is relative to the target or absolute. For `public`/`private` it
must resolve inside the target and outside the root. `ignore` also accepts a
path inside the root and reads the package from its first component.

## Commands and JSON rows

### install

Restow both packages: `stow --restow public private`. Idempotent; a clean
tree prints `nothing to do`. Rows:

```jsonl
{"action":"link","package":"public","path":".examplerc","target":"../dotfiles/public/.examplerc"}
{"action":"unlink","package":"private","path":".awsrc","reason":"source_missing"}
{"action":"mkdir","path":".config"}
{"action":"unfold","package":"public","path":".config"}
{"action":"rmdir","path":".config/old"}
{"_meta":{"has_more":false,"created":1,"removed":1,"unfolded":1}}
```

`action` is one of `link`, `unlink`, `mkdir`, `rmdir`, `unfold`, `refold`.
`target` is the link text. `reason` is `source_missing` on an unlink of a
broken link. `_meta` counters: `created`, `removed`, `unfolded`, `refolded`.

### status

Read-only. Output is the result, so it goes to stdout in both modes and
`--quiet` does not suppress it. Rows are buffered; a git failure leaves
stdout empty.

```jsonl
{"kind":"package","package":"public","dirty":true,"changes":1,"upstream":"origin/main","ahead":0,"behind":1}
{"kind":"package","package":"private","dirty":false,"changes":0,"upstream":null,"ahead":null,"behind":null}
{"kind":"conflict","package":"public","path":".config/mine","detail":".config/mine exists and is not a dotfiles symlink","hint":"dfm public .config/mine to adopt it, or remove it and rerun"}
{"kind":"broken_link","package":"private","path":".awsrc","target":"../dotfiles/private/.awsrc"}
{"_meta":{"has_more":false,"dirty":1,"conflicts":1,"broken_links":1,"pending":1}}
```

`upstream`, `ahead`, `behind` are null when the branch has no upstream.
Ahead/behind is against the local tracking ref; `status` never fetches.
`changes` is the porcelain line count including untracked files. `pending`
counts every action the next `install` would apply. Exit 2 when
`conflicts` is nonzero. Dirty, ahead, behind, broken links, no upstream, and
detached HEAD are states, not errors.

### public and private

Move the path into the package, then run `install`. The install is planned
on the current tree first; a conflict anywhere exits 2 and moves nothing.
`_meta` gains `adopted`. `--dry-run` prints the `adopt` row but not the
install plan that follows.

```jsonl
{"action":"adopt","package":"public","path":".newrc","from":".newrc","to":"public/.newrc"}
{"action":"link","package":"public","path":".newrc","target":"../dotfiles/public/.newrc"}
{"_meta":{"has_more":false,"created":1,"adopted":1}}
```

A symlink leaf is adopted as a link, not resolved. A directory moves whole
and becomes a folded link.

### ignore

Append `/<package-relative path>` to the owning package's `.gitignore`.
Ownership walks upward from the path to the first dfm-owned link. Does not
run `install`. `_meta` gains `ignored`.

```jsonl
{"action":"ignore","package":"public","path":".config/example/cache","file":"public/.gitignore","line":"/.config/example/cache"}
{"_meta":{"has_more":false,"ignored":1}}
```

An already-present line is `{"action":"noop",...,"reason":"already_ignored"}`
with exit 0.

### pull

Dirty check across both packages, then per package fetch and rebase onto
`FETCH_HEAD`, then `install`, then `post-pull.sh` per package (public first,
cwd set to the package). Rows stream as they happen; a mid-run fatal leaves
rows without `_meta`.

```jsonl
{"action":"pull","package":"public","before":"4f9085e...","after":"df051e4..."}
{"action":"pull","package":"private","before":"87c61a4...","after":"87c61a4..."}
{"action":"link","package":"public","path":".pushedrc","target":"../dotfiles/public/.pushedrc"}
{"action":"hook","package":"public","exit":0}
{"action":"skip","package":"private","reason":"absent"}
{"_meta":{"has_more":false,"created":1,"pulled":2,"hooks":1}}
```

`after` is null under `--dry-run`, which fetches nothing but still runs the
dirty check. `skip` reasons: `absent`, `not_executable`, `no_hooks`. Under
`--json`, hook stdout goes to stderr. `post-pull.sh` installs packages and is
slow; pass `--no-hooks` when only the links matter.

### version

Bare version on stdout; `--json` gives `{"version":"..."}` then `_meta`.

## Errors

Every fatal error is one JSON object on stderr in every mode: `error`
(stable code), `detail`, `hint`, `path`. Follow the hint. Conflicts print one
object per path before exiting.

| `error` | Exit | Meaning |
|---|---|---|
| `conflict` | 2 | Target path exists and is not a dfm link. Nothing changed. |
| `dirty_tree` | 1 | `pull`: a package has uncommitted changes. Nothing fetched. |
| `hook_failed` | 1 | `post-pull.sh` exited non-zero. Packages are already updated and linked. |
| `already_tracked` | 1 | Adopt: path is already a dfm link, or exists in the package. |
| `contains_tracked` | 1 | Adopt: directory holds a dfm link below it. Adopt its children. |
| `inside_root` | 1 | Adopt: path resolves into `~/dotfiles`. |
| `outside_target` | 1 | Path is under neither the target nor the root. |
| `not_found` | 1 | Path does not exist. |
| `not_tracked` | 1 | `ignore`: no dfm-owned ancestor. Adopt it first. |
| `cross_device` | 1 | Adopt: target and root on different filesystems. |
| `adopt_failed`, `ignore_failed`, `apply_failed` | 1 | Filesystem operation failed; `detail` has the OS error. |
| `bad_ignore_pattern` | 1 | A `.stow-local-ignore` line does not compile. `path` names the file. |
| `package_missing`, `root_missing`, `target_missing` | 1 | Layout is wrong for `--root`/`--target`. |
| `invalid_arguments` | 1 | Bad flags or arguments. |
| `git_failed` | 4 | `git` failed. `detail` is prefixed with the package. A stopped rebase hints `git rebase --abort`. |

Exit codes: `0` success (including `--dry-run`), `1` general error, `2`
conflict, `3` reserved, `4` git or network error.

## Stow semantics to keep in mind

- Links are relative: one `..` per level below the target
  (`.config/nvim/init.lua -> ../../dotfiles/public/.config/nvim/init.lua`).
- A directory only one package populates is one folded link. When the second
  package adds a file under it, `install` unfolds: the link becomes a real
  directory and each child is linked. A fresh two-package install reports
  every shared directory as `unfold`.
- Refold never happens under restow; a directory once unfolded stays a real
  directory. The `refold` action exists but is a no-op in practice.
- A symlink committed inside a package is linked as a file, not resolved.
- Ownership is textual: a link is ours when its text joined with its
  directory starts with `<root>/`. An absolute symlink into the root is a
  conflict, not ours.
- Broken links whose package file was deleted are removed on `install`
  (`unlink`, `source_missing`), but only inside directories the package still
  has.
- `.stow-local-ignore` replaces stow's default ignore list entirely when
  present. Adopting a path the list matches moves it and then never links it,
  silently.

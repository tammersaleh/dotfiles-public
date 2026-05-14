---
paths:
  - "**/*.{go,py,rs,ts,tsx,js,jsx,rb,sh,zsh,bash,lua,zig,c,cc,cpp,h,hpp,java,kt,swift,scala,clj,ex,exs,erl,hs,ml,pl,php,sql}"
  - "**/Cargo.toml"
  - "**/package.json"
  - "**/go.mod"
  - "**/pyproject.toml"
---

# Code repos

## Where

`~/src/github.com` is where I checkout and write source code.

The directory structure mirrors the Git repository URL. The Terraform project, for example, would be found under `~/src/github.com/hashicorp/terraform`. This structure is made easy through [my `git grab` command](https://github.com/tammersaleh/dotfiles-public/tree/master/bin/git-grab).

If you're analyzing someone else's code, it's faster to `git grab org/repo` and use local fs tools (LSP, `ag`) to scan the code under `~/src/github.com/org/repo`.

## IMPORTANT: Red, Green, Refactor

If the repo has tests, ALWAYS write new tests to show the expected behavior, and watch those tests fail, BEFORE implementing the feature.

Once the tests pass, YOU ARE NOT DONE. Look through the changes in the context of the existing code and find places to simplify and refactor.

If there aren't any tests, think of ways you can test the code manually to show correctness.

## Shell scripts

Follow the template in `~/dotfiles/public/.config/nvim/templates/sh` for all new bash scripts. It includes strict mode, error trapping, debug support, and `cd "$(dirname "$0")"` so scripts work from any directory.

Always use long flags (`--global`, `--yes`) instead of short flags (`-g`, `-y`) in scripts for self-documentation.

## Preferred tooling

- Prefer Mise over Makefiles, but always default to whatever is already in place.
- If there's a locally configured tool runner, use that instead of running the underlying commands. For example `mise tests` instead of `go test ./...`
- When writing greenfield CLIs, prefer Golang, and prefer Kong over Cobra.
- Prefer `uv` for Python.
- If writing a Python script makes use of the `uv` [shebang-with-dependencies pattern](https://docs.astral.sh/uv/guides/scripts/#declaring-script-dependencies)

## Searching codebases

Prefer LSP over Grep/Read for code navigation - it's faster, precise, and avoids reading entire files:

- `workspaceSymbol` to find where something is defined
- `findReferences` to see all usages across the codebase
- `goToDefinition` / `goToImplementation` to jump to source
- `hover` for type info without reading the file

Use Grep only when LSP isn't available or for text/pattern searches (comments, strings, config). Even then, suggest I install the missing LSP for you.

After writing or editing code, check LSP diagnostics and fix errors before proceeding.

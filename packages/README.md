This is where I manage package installations across multiple machines. Run `~/packages/go` (from any directory) to install or update everything.

Everything is in `Brewfile`. `brew bundle` natively manages formulae, casks, Go tools, npm packages, and more. `brew bundle cleanup --force` removes anything not listed, including stale Go binaries from `$GOBIN`.

Keep sections sorted alphabetically with a one-line comment describing what each entry is.

To add a package:

```bash
brew bundle add NAME --install                       # formula
brew bundle add --cask NAME --install                # cask
brew bundle add --go  github.com/foo/bar --install   # go tool
brew bundle add --npm NAME --install                 # npm package
```

Or just edit `Brewfile` directly and run `~/packages/go`.

`go` uses `set -Eeuo pipefail`, so any error aborts the whole run before later packages install. If it dies on an untrusted tap, run `brew trust <tap>` for each flagged tap, then re-run.

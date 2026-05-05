This is where I manage package installations across multiple machines. Run `./go` to install or update everything.

## Homebrew

Add formulae and casks to `Brewfile`. Keep sections sorted alphabetically with a one-line comment describing what each entry is.

## Bun

Add to `dependencies` in `package.json`. Binaries are symlinked into `~/.bun/bin/`.

## Go

Add tools with:

```bash
go get -tool github.com/foo/bar@latest
```

Tracked as `tool` directives in `go.mod`. Binaries land in `$GOBIN` (`~/.local/bin`).

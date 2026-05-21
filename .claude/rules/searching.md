# Searching local files

Prefer modern Rust alternatives over POSIX defaults: `rg` for content, `fd` for filenames. Both are faster, respect `.gitignore`, and skip binaries by default.

## Content search: rg over grep

- `rg PATTERN PATH` instead of `grep -ri PATTERN PATH 2>/dev/null | grep -v ".git" | head -20`
- `rg -l PATTERN` when you only need filenames
- `rg -c PATTERN` when you only need match counts

## Filename search: fd over find

- `fd PATTERN` instead of `find . -name "*PATTERN*"`
- `fd -e py` to filter by extension
- `fd -t f` / `fd -t d` for files-only / dirs-only
- `fd PATTERN -x CMD` to run a command per match (replaces `find -exec`)
- `fd` skips hidden files by default; use `-H` to include them, or `-u` for fully unrestricted

## Protect the context window

Raw output can be thousands of lines. Pick one:

- **Small expected result set**: pipe to `head`
  - `rg PATTERN | head -50`
  - `fd -e ts | head -50`
- **Unknown or large**: pipe to a tmp file, then analyze
  - `rg PATTERN > /tmp/search.txt && wc -l /tmp/search.txt`
  - `fd -e py > /tmp/files.txt && wc -l /tmp/files.txt`
  - Then `head`, `tail`, `rg` again to filter, or `awk` to extract
  - Lets you iterate without re-running the search

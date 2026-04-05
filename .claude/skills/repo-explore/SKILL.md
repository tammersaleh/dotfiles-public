---
name: repo-explore
description: Explore external GitHub repositories by cloning them locally via `git grab` and using the Explore agent for codebase analysis. Triggers on "explore repo", "look at this repo", or any GitHub URL with an exploratory question.
---

# Repo Explore

Clone and explore external GitHub repositories using the Explore agent.

## Repo Location

All repos live under `~/src/github.com/<owner>/<repo>/`, managed by `git grab`.

## Workflow

### 1. Parse Repository Input

Extract owner and repo from any of:

- `https://github.com/owner/repo`
- `git@github.com:owner/repo.git`
- `owner/repo` (shorthand)
- `github.com/owner/repo`

### 2. Clone If Needed

```bash
ls ~/src/github.com/<owner>/<repo>/ 2>/dev/null
```

If it doesn't exist:

```bash
git grab <owner>/<repo>
```

If it does exist, optionally pull latest:

```bash
cd ~/src/github.com/<owner>/<repo> && git pull --ff-only
```

### 3. Explore with Agent

Use the Agent tool with `subagent_type=Explore` for all questions about the repo.

```
Agent(
  subagent_type="Explore",
  prompt="""In ~/src/github.com/<owner>/<repo>/, <the user's question>.

Include file paths and line numbers with code snippets.
End with a 'Key Files' table: File | Purpose | Start Here If...
"""
)
```

Do NOT manually browse files when the Explore agent can do it.

### 4. Version Checkout

If the user asks about a specific version, or the repo is a dependency of the current project:

```bash
cd ~/src/github.com/<owner>/<repo>
git fetch --all --tags
git checkout <tag>
```

Try tag formats: `v1.2.3`, `1.2.3`, `release-1.2.3`, `release/1.2.3`.

## Notes

- For private repos, clone works if git credentials are configured.
- Large repos may take time to clone - mention it to the user.

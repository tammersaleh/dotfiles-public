---
name: plaid-cli
description: "Link bank accounts and pull transactions via the `plaid-cli` tool (landakram/plaid-cli, Plaid API). Use when Tammer wants to connect a bank/institution to Plaid, list linked accounts, or export transactions to JSON or CSV from the command line."
compatibility: "Requires plaid-cli (github.com/landakram/plaid-cli) on PATH, Plaid API credentials in the environment (via envsec, see Configuration) or ~/.plaid-cli/config.toml, and at least one institution linked via 'plaid-cli link'."
---

# plaid-cli

Source: https://github.com/landakram/plaid-cli (v0.0.6, unmaintained since 2021). Plaid API docs: https://plaid.com/docs/.

`plaid-cli` links bank institutions through Plaid and pulls their transactions and accounts. Installed as a Go tool via the Brewfile (`go "github.com/landakram/plaid-cli"`); binary lives at `~/.local/bin/plaid-cli`.

## Environment gotcha (read first)

The CLI accepts only `PLAID_ENVIRONMENT=development` or `production`. It rejects `sandbox` with `Invalid plaid environment`.

Plaid decommissioned the `development` environment on 2024-06-20, so `production` is the only value that works today. Production needs approved production access on the Plaid account. The free Sandbox (fake banks) cannot be used with this CLI unmodified.

If a link or API call returns an environment or auth error, the credentials or the environment are the first suspects, not the bank.

## Core rules

- This connects Tammer's real bank accounts and pulls real financial data. Read freely. `link` is interactive and touches live bank credentials through Plaid's hosted flow, so confirm before running it.
- Credentials are secrets. Never print `PLAID_SECRET` or the contents of `~/.plaid-cli/config.toml` or `tokens.json`.
- Access tokens are stored unencrypted (see Data storage). Treat that directory as sensitive.

## Configuration

Credentials come from environment variables. They are stored in 1Password and reach the shell via envsec, not a plaintext config file.

The 1Password item is `Plaid API` in the personal account (`my.1password.com`, Private vault), tagged `shell-env`. It holds four CONCEALED fields whose labels are the env var names:

```text
PLAID_CLIENT_ID    # from https://dashboard.plaid.com/team/keys
PLAID_SECRET       # production secret
PLAID_ENVIRONMENT  # production
PLAID_COUNTRIES    # US
```

After adding or rotating a field, run `envsec sync` and open a new shell (see the private dotfiles CLAUDE.md secrets section). `envsec list` shows which vars are wired without revealing values.

The CLI also reads `~/.plaid-cli/config.toml` if env vars are absent, but envsec is the configured path here.

## Login (linking an institution)

1. Confirm credentials are set: `plaid-cli tokens` runs without a credentials warning.
2. Run `plaid-cli link`. It starts a local webserver on port 8080 and opens the browser to Plaid Link.
3. Complete the bank's auth flow in the browser (this is Tammer's to do; it uses his real bank login).
4. On success the CLI writes the item ID and access token to `~/.plaid-cli/data/tokens.json` and prints the item ID.
5. Give the item a friendly name: `plaid-cli alias <ITEM-ID> <name>`.

Change the port with `-p/--port` if 8080 is taken. Relink an expired login (2FA, password change) by re-running `plaid-cli link <ITEM-ID-OR-ALIAS>`.

## Commands

Most commands take an `ITEM-ID-OR-ALIAS` to pick the institution.

```bash
plaid-cli tokens                         # list linked item IDs and access tokens
plaid-cli aliases                        # list alias -> item ID mappings
plaid-cli alias <ITEM-ID> <NAME>         # name an item
plaid-cli link [ITEM-ID-OR-ALIAS]        # link, or relink an existing item
plaid-cli accounts <ITEM-ID-OR-ALIAS>    # list accounts and their account IDs
plaid-cli institution <ITEM-ID-OR-ALIAS> [-s|--status] [-m|--optional-metadata]
```

### Transactions

`--from` and `--to` are required, both `YYYY-MM-DD`.

```bash
plaid-cli transactions <ITEM-ID-OR-ALIAS> --from 2026-08-01 --to 2026-08-31
plaid-cli transactions checking --from 2026-08-01 --to 2026-08-31 -o csv > out.csv
plaid-cli transactions checking --from 2026-08-01 --to 2026-08-31 -a <ACCOUNT-ID>
```

Flags: `-f/--from` (required), `-t/--to` (required), `-o/--output-format` (`json` default, or `csv`), `-a/--account-id` (filter to one account; get IDs from `accounts`).

Default JSON output goes to stdout; pipe through `jq`. Get an account ID from `plaid-cli accounts` before filtering.

## Data storage

- `~/.plaid-cli/config.toml` - credentials (if not using env vars).
- `~/.plaid-cli/data/tokens.json` - item ID to access token map, unencrypted.
- `~/.plaid-cli/data/aliases.json` - alias to item ID map.

Empty `tokens.json` / `aliases.json` print a harmless "unexpected end of JSON input" warning on every run before anything is linked.

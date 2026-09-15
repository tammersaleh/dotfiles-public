---
name: secrets
description: "How Tammer stores secrets: 1Password as source of truth, exported to the shell via envsec. Use when a tool or script needs an API key, token, or other credential, when adding or rotating a secret, or when a command fails because a credential env var is missing. Never put secret values in dotfiles or any repo; use this pattern instead."
---

# Secrets (envsec)

Secrets never live in dotfiles or any repo. The source of truth is 1Password. `envsec` (github.com/tammersaleh/envsec, installed as a cask) copies tagged 1Password fields into the macOS login keychain, and `~/.zsh/d/secrets.zsh` evals `envsec env` at shell start to export them. Shells never call `op`.

## How a var gets into the shell

- An item opts in with the tag `shell-env` in Tammer's personal account.
- Every CONCEALED field on that item whose label is a valid env var name is exported under that label. Plain-text (non-concealed) fields are ignored.
- `envsec sync` writes the current tagged fields to the keychain. New interactive shells then have the vars.
- A non-interactive shell (the Bash tool, a script) does not load `secrets.zsh`, so it starts without the vars. Prefix commands with `eval "$(envsec env)"` to load them for that call.

## Keep all of a tool's vars in one item

One 1Password item per tool, holding every env var that tool needs, even the non-secret ones (an environment name, a region, an account id). Make them CONCEALED fields too so envsec exports them. One item is one place to read the config and one place to rotate it.

Example: the `Plaid API` item holds `PLAID_CLIENT_ID`, `PLAID_SECRET`, and `PLAID_ENV` (value `production`, not secret but kept with the rest).

## Adding a secret: Claude builds the item, Tammer fills the value

Claude creates the item and its field structure but never sees or types the secret. Tammer enters the value in the 1Password app.

1. Claude creates the item in the personal account, tagged `shell-env`, with the non-secret vars set and each secret var seeded with a placeholder. `op` drops empty-valued fields on create, so give secret fields a placeholder like `REPLACE_ME`. Say beforehand that a Touch ID prompt is coming.

   ```bash
   acct=$(op account get --format json | jq -r .id)
   op item create --account "$acct" --category "API Credential" \
     --title "<Tool> API" --tags shell-env \
     'TOOL_ENV[password]=production'
   op item edit <item-id> --account "$acct" \
     'TOOL_CLIENT_ID[password]=REPLACE_ME' 'TOOL_SECRET[password]=REPLACE_ME'
   ```

2. Claude hands Tammer a deep link to the item (build it from the create output's item and vault IDs plus the account UUID):

   ```text
   onepassword://view-item?a=<ACCOUNT_UUID>&v=<VAULT_ID>&i=<ITEM_ID>
   ```

3. Tammer opens 1Password, presses `shift-cmd-R` to reload its database (items Claude created through the CLI do not appear until the app re-syncs), then opens the item and replaces each `REPLACE_ME`. Field type must stay `Password` (concealed) or envsec skips it.

4. Tammer tells Claude the values are in. Claude runs `envsec sync` (a keychain-unlock or Touch ID prompt), then `envsec check` to confirm every var reports `ok`. For the current session, `eval "$(envsec env)"`; Tammer's own new shells pick the vars up automatically.

## Rotating a secret

Update the field value in 1Password, run `envsec sync`, open a new shell. To rename or drop a var, edit the item (`op item edit <id> 'NEW[password]=v' 'OLD[delete]'`) and re-sync.

## Commands

```bash
envsec sync    # copy tagged 1Password fields into the keychain (calls op; prompts)
envsec env     # print export lines for eval (reads keychain; no op)
envsec check   # compare 1Password against the keychain, no writes
envsec list    # show which vars come from which item, without values
```

Never run `envsec sync` from shell startup or a scheduled job; `op` prompts. See the private dotfiles CLAUDE.md for the field denylist and delivery details.
